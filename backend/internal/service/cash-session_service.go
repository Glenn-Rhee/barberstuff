package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"errors"
	"runtime"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

type CashSessionService interface {
	CreateCashSession(req dto.CreateCashSession, claims *lib.CustomClaims) error
}

type cashSessionService struct {
	cashSessionRepo repository.CashSessionRepository
	storeRepo       repository.StoreRepository
	staffRepo       repository.StaffRepository
}

func NewCashSessionService(csr repository.CashSessionRepository, sr repository.StoreRepository, str repository.StaffRepository) CashSessionService {
	return &cashSessionService{cashSessionRepo: csr, storeRepo: sr, staffRepo: str}
}

func (s *cashSessionService) CreateCashSession(req dto.CreateCashSession, claims *lib.CustomClaims) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat saldo awal!"
	_, filePath, _, _ := runtime.Caller(0)

	idStaff, err := uuid.Parse(claims.UserId)
	if err != nil {
		return errors.New("Data anda tidak valid.")
	}

	dataStore, err := s.staffRepo.FindOne("id = ?", idStaff)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Akun tidak ditemukan.")
		}

		helper.Logger("find one staff account.", filePath, err)
		return errors.New(BASE_MESSAGE)
	}
	if dataStore.IdStore == nil {
		return errors.New("Anda tidak memiliki akses.")
	}
	idStore := *dataStore.IdStore
	_, err = s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko tidak ditemukan.")
		}

		helper.Logger("find one store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	// Kalau kas sebelumnya tidak ditutup tidak bisa membuat.
	_, err = s.cashSessionRepo.FindOne("id_store = ? AND status = ?", idStore, entity.SessionOpen)
	if err == nil {
		return errors.New("Anda belum menutup kas sebelumnya.")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("find cash session", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	dataCashSession := entity.CashSession{
		ID:         uuid.New(),
		IDStore:    idStore,
		SaldoBegin: decimal.NewFromFloat(req.SaldoBegin),
		Status:     entity.SessionOpen,
	}

	err = s.cashSessionRepo.Create(&dataCashSession)
	if err != nil {
		helper.Logger("create cash session", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
