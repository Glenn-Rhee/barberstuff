package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"errors"
	"runtime"
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

type CashSessionService interface {
	CreateCashSession(req dto.CreateCashSession, claims *lib.CustomClaims) (dto.CreateCashSessionResponse, error)
	GetToday(claims *lib.CustomClaims) (dto.GetCashSessionResponse, error)
	CloseCashSession(req dto.CloseCashSessionRequest, claims *lib.CustomClaims) (dto.CloseCashSessionResponse, error)
}

type cashSessionService struct {
	cashSessionRepo repository.CashSessionRepository
	storeRepo       repository.StoreRepository
	staffRepo       repository.StaffRepository
}

func NewCashSessionService(csr repository.CashSessionRepository, sr repository.StoreRepository, str repository.StaffRepository) CashSessionService {
	return &cashSessionService{cashSessionRepo: csr, storeRepo: sr, staffRepo: str}
}

func (s *cashSessionService) CreateCashSession(req dto.CreateCashSession, claims *lib.CustomClaims) (dto.CreateCashSessionResponse, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat saldo awal!"
	_, filePath, _, _ := runtime.Caller(0)

	idStaff, err := uuid.Parse(claims.UserId)
	if err != nil {
		return dto.CreateCashSessionResponse{}, errors.New("Data anda tidak valid.")
	}

	dataStaff, err := s.staffRepo.FindOne("id = ?", idStaff)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.CreateCashSessionResponse{}, errors.New("Akun tidak ditemukan.")
		}

		helper.Logger("find one staff account.", filePath, err)
		return dto.CreateCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}
	if dataStaff.IdStore == nil {
		return dto.CreateCashSessionResponse{}, errors.New("Anda tidak memiliki akses.")
	}

	idStore := *dataStaff.IdStore
	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.CreateCashSessionResponse{}, errors.New("Toko tidak ditemukan.")
		}

		helper.Logger("find one store", filePath, err)
		return dto.CreateCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	// Kalau kas sebelumnya tidak ditutup tidak bisa membuat.
	_, err = s.cashSessionRepo.FindOne("id_store = ? AND status = ?", idStore, entity.SessionOpen)
	if err == nil {
		return dto.CreateCashSessionResponse{}, errors.New("Anda belum menutup kas sebelumnya.")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("find cash session", filePath, err)
		return dto.CreateCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	loc, _ := time.LoadLocation(string(dataStore.Timezone))
	now := time.Now().In(loc)
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, loc)
	tomorrow := today.Add(24 * time.Hour)

	_, err = s.cashSessionRepo.FindOne(
		"id_store = ? AND created_at >= ? AND created_at < ?",
		idStore, today, tomorrow,
	)

	if err == nil {
		return dto.CreateCashSessionResponse{}, errors.New("Kas untuk hari ini sudah pernah dibuka.")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("find cash session today", filePath, err)
		return dto.CreateCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	dataCashSession := entity.CashSession{
		ID:         uuid.New(),
		IDStore:    idStore,
		SaldoBegin: decimal.NewFromFloat(req.SaldoBegin),
		Status:     entity.SessionOpen,
	}

	err = s.cashSessionRepo.Create(&dataCashSession)
	if err != nil {
		if helper.IsUniqueViolation(err) {
			return dto.CreateCashSessionResponse{}, errors.New("Kas untuk hari ini sudah pernah dibuka.")
		}
		helper.Logger("create cash session", filePath, err)
		return dto.CreateCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	return dto.CreateCashSessionResponse{
		Id:         dataCashSession.ID,
		SaldoBegin: dataCashSession.SaldoBegin,
	}, nil
}

func (s *cashSessionService) GetToday(claims *lib.CustomClaims) (dto.GetCashSessionResponse, error) {
	const BASE_MESSAGE = "Terjadi kesalahan mengambil data."
	_, filePath, _, _ := runtime.Caller(0)

	idStaff, err := uuid.Parse(claims.UserId)
	if err != nil {
		return dto.GetCashSessionResponse{}, errors.New("Data anda tidak valid.")
	}

	dataStaff, err := s.staffRepo.FindOne("id = ?", idStaff)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.GetCashSessionResponse{}, errors.New("Akun tidak ditemukan. Mohon untuk login ulang!")
		}

		helper.Logger("find one staff", filePath, err)
		return dto.GetCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	if dataStaff.IdStore == nil {
		return dto.GetCashSessionResponse{}, errors.New("Anda tidak memiliki akses.")
	}

	dataStore, err := s.storeRepo.FindOne("id = ?", dataStaff.IdStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.GetCashSessionResponse{}, errors.New("Toko tidak dapat ditemukan.")
		}

		helper.Logger("find one store", filePath, err)
		return dto.GetCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	dataCashSession, err := s.cashSessionRepo.FindOne("id_store = ? AND status = ?", dataStore.ID, entity.SessionOpen)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.GetCashSessionResponse{}, errors.New("Transaksi pembukuan telah ditutup.")
		}

		helper.Logger("find one staff", filePath, err)
		return dto.GetCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	var totalIncomeCash decimal.Decimal
	var totalIncomeCashless decimal.Decimal
	var totalOutcome decimal.Decimal
	var transactions = make([]dto.TransactionResponse, 0, len(dataCashSession.Transactions))
	for _, v := range dataCashSession.Transactions {
		if v.TransactionType == entity.TransactionIncome {
			if v.PaymentType == entity.PaymentCash {
				totalIncomeCash = totalIncomeCash.Add(v.Amount)
			} else {
				totalIncomeCashless = totalIncomeCashless.Add(v.Amount)
			}
		} else {
			totalOutcome = totalOutcome.Add(v.Amount)
		}

		transactions = append(transactions, dto.TransactionResponse{
			Id:              v.ID,
			Title:           v.Title,
			PaymentType:     v.PaymentType,
			Amount:          v.Amount,
			TransactionType: v.TransactionType,
			Description:     v.Description,
			CreatedAt:       v.CreatedAt,
		})
	}

	return dto.GetCashSessionResponse{
		Id:                  dataCashSession.ID,
		SaldoBegin:          dataCashSession.SaldoBegin,
		TotalIncomeCash:     totalIncomeCash,
		TotalIncomeCashless: totalIncomeCashless,
		TotalOutcome:        totalOutcome,
		Transactions:        transactions,
	}, nil
}

func (s *cashSessionService) CloseCashSession(req dto.CloseCashSessionRequest, claims *lib.CustomClaims) (dto.CloseCashSessionResponse, error) {
	const BASE_MESSAGE = "Terjadi kesalahan mengambil data."
	_, filePath, _, _ := runtime.Caller(0)

	idCashSession, err := uuid.Parse(req.IdCashSession)
	if err != nil {
		return dto.CloseCashSessionResponse{}, errors.New("Id cash session tidak valid.")
	}

	idStaff, err := uuid.Parse(claims.UserId)
	if err != nil {
		return dto.CloseCashSessionResponse{}, errors.New("Akun tidak valid. Silahkan login ulang.")
	}

	dataStaff, err := s.staffRepo.FindOne("id = ?", idStaff)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.CloseCashSessionResponse{}, errors.New("Akun tidak ditemukan. Silahkan login ulang.")
		}

		helper.Logger("find one staff", filePath, err)
		return dto.CloseCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	if dataStaff.IdStore == nil {
		return dto.CloseCashSessionResponse{}, errors.New("Anda tidak memiliki akses")
	}

	dataCashSession, err := s.cashSessionRepo.FindOne("id = ? AND status = ?", idCashSession, entity.SessionOpen)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.CloseCashSessionResponse{}, errors.New("Data pembukuan tidak ditemukan atau telah ditutup.")
		}

		helper.Logger("find one cash session", filePath, err)
		return dto.CloseCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	if dataCashSession.IDStore != *dataStaff.IdStore {
		return dto.CloseCashSessionResponse{}, errors.New("Pembukuan ini bukan milik anda.")
	}

	// Total uang di sistem
	var totalAmountIncome decimal.Decimal
	var totalAmountOutcome decimal.Decimal
	for _, v := range dataCashSession.Transactions {
		if v.TransactionType == entity.TransactionIncome && v.PaymentType == entity.PaymentCash {
			totalAmountIncome = totalAmountIncome.Add(v.Amount)
		}

		if v.TransactionType == entity.TransactionOutcome {
			totalAmountOutcome = totalAmountOutcome.Add(v.Amount)
		}
	}
	amountActual := decimal.NewFromFloat(req.AmountActual)
	totalAmount := totalAmountIncome.Sub(totalAmountOutcome).Add(dataCashSession.SaldoBegin)

	amountDifference := amountActual.Sub(totalAmount)
	var status dto.StatusCloseCash
	if amountDifference.IsNegative() {
		status = dto.StatusMinus
	} else if amountDifference.IsPositive() {
		status = dto.StatusPositive
	} else {
		status = dto.StatusBalance
	}

	var scopes []func(*gorm.DB) *gorm.DB
	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.
			Where("id = ?", idCashSession).
			Where("status = ?", entity.SessionOpen)
	})

	var updates = map[string]interface{}{
		"amount_actual": &amountActual,
		"status":        entity.SessionClosed,
	}

	rowsAffected, err := s.cashSessionRepo.Updates(updates, scopes...)
	if err != nil {
		return dto.CloseCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	if rowsAffected == 0 {
		return dto.CloseCashSessionResponse{}, errors.New("Pembukuan tidak ditemukan, atau telah ditutup.")
	}

	return dto.CloseCashSessionResponse{
		AmountDifference: amountDifference,
		Status:           status,
	}, nil
}
