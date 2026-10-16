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
	"gorm.io/gorm/clause"
)

type CashSessionService interface {
	CreateCashSession(req dto.CreateCashSession, claims *lib.CustomClaims) (dto.CreateCashSessionResponse, error)
	GetToday(claims *lib.CustomClaims) (dto.GetCashSessionResponse, error)
	CloseCashSession(req dto.CloseCashSessionRequest, claims *lib.CustomClaims) (dto.CloseCashSessionResponse, error)
	GetHistory(claims *lib.CustomClaims, req dto.HistoryCashSessionReq) ([]dto.HistoryCashSessionRes, dto.ResponsePagination, error)
}

type cashSessionService struct {
	cashSessionRepo repository.CashSessionRepository
	storeRepo       repository.StoreRepository
	staffRepo       repository.StaffRepository
	serviceRepo     repository.ServiceRepository
	employeeRepo    repository.EmployeeRepository
	db              *gorm.DB
}

func NewCashSessionService(
	csr repository.CashSessionRepository,
	sr repository.StoreRepository,
	str repository.StaffRepository,
	svr repository.ServiceRepository,
	er repository.EmployeeRepository,
	db *gorm.DB,
) CashSessionService {
	return &cashSessionService{
		cashSessionRepo: csr,
		storeRepo:       sr,
		staffRepo:       str,
		db:              db,
		serviceRepo:     svr,
		employeeRepo:    er,
	}
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

	var countScopes []func(*gorm.DB) *gorm.DB
	countScopes = append(countScopes, func(d *gorm.DB) *gorm.DB {
		return d.Where("id_store = ?", idStore)
	})

	totalService, err := s.serviceRepo.Count(countScopes...)
	if err != nil {
		return dto.CreateCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	if totalService <= 0 {
		return dto.CreateCashSessionResponse{}, errors.New("Tidak dapat membuka kasir, tidak ada service.")
	}

	totalCapster, err := s.employeeRepo.CountCapster(countScopes...)
	if err != nil {
		return dto.CreateCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	if totalCapster <= 0 {
		return dto.CreateCashSessionResponse{}, errors.New("Tidak dapat membuka kasir, tidak ada capster.")
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
		IDStaff:    idStaff,
		SaldoBegin: decimal.NewFromFloat(req.SaldoBegin),
		Status:     entity.SessionOpen,
	}

	var errStoreNotFound = errors.New("Toko tidak ditemukan.")
	err = s.db.Transaction(func(tx *gorm.DB) error {
		err = s.cashSessionRepo.Create(tx, &dataCashSession)
		if err != nil {
			return err
		}

		storeUpdates := map[string]interface{}{
			"status": entity.StoreStatusOpen,
		}

		rowsAffected, err := s.storeRepo.Updates(tx, storeUpdates, idStore)
		if err != nil {
			return err
		}

		if rowsAffected == 0 {
			return errStoreNotFound
		}

		return nil
	})

	if err != nil {
		if helper.IsUniqueViolation(err) {
			return dto.CreateCashSessionResponse{}, errors.New("Kas untuk hari ini sudah pernah dibuka.")
		}

		if errors.Is(err, errStoreNotFound) {
			return dto.CreateCashSessionResponse{}, err
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
	var totalVoidIncome, totalVoidOutcome decimal.Decimal
	var transactions = make([]dto.TransactionResponse, 0, len(dataCashSession.Transactions))
	for _, v := range dataCashSession.Transactions {
		if v.DeletedAt != nil {
			if v.TransactionType == entity.TransactionIncome {
				totalVoidIncome = totalVoidIncome.Add(v.Amount)
			} else {
				totalVoidOutcome = totalVoidOutcome.Add(v.Amount)
			}
		} else {
			if v.TransactionType == entity.TransactionIncome {
				if v.PaymentType == entity.PaymentCash {
					totalIncomeCash = totalIncomeCash.Add(v.Amount)
				} else {
					totalIncomeCashless = totalIncomeCashless.Add(v.Amount)
				}
			} else {
				totalOutcome = totalOutcome.Add(v.Amount)
			}
		}

		transactions = append(transactions, dto.TransactionResponse{
			Id:              v.ID,
			Title:           v.Title,
			PaymentType:     v.PaymentType,
			Amount:          v.Amount,
			TransactionType: v.TransactionType,
			Description:     v.Description,
			CreatedAt:       v.CreatedAt,
			DeletedAt:       v.DeletedAt,
		})
	}

	return dto.GetCashSessionResponse{
		Id:                  dataCashSession.ID,
		SaldoBegin:          dataCashSession.SaldoBegin,
		TotalIncomeCash:     totalIncomeCash,
		TotalIncomeCashless: totalIncomeCashless,
		TotalOutcome:        totalOutcome,
		Transactions:        transactions,
		TotalVoidIncome:     totalVoidIncome,
		TotalVoidOutcome:    totalVoidOutcome,
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

	dataStore, err := s.storeRepo.FindOne("id = ?", dataStaff.IdStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.CloseCashSessionResponse{}, errors.New("Toko tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("find one store", filePath, err)
		return dto.CloseCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	loc, err := time.LoadLocation(string(dataStore.Timezone))
	if err != nil {
		helper.Logger("load location", filePath, err)
		return dto.CloseCashSessionResponse{}, errors.New(BASE_MESSAGE)
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

	// Validasi Jam operasional
	now := time.Now().In(loc)
	sessionCreatedAt := dataCashSession.CreatedAt.In(loc)

	isSameDay := now.Year() == sessionCreatedAt.Year() &&
		now.YearDay() == sessionCreatedAt.YearDay()

	// Kalau kas ini dibuat hari ini
	if isSameDay {
		openTime := time.Date(
			now.Year(), now.Month(), now.Day(),
			dataStore.OpenHour.Hour(), dataStore.OpenHour.Minute(), dataStore.OpenHour.Second(), 0,
			loc,
		)

		closeTime := time.Date(
			now.Year(), now.Month(), now.Day(),
			dataStore.CloseHour.Hour(), dataStore.CloseHour.Minute(), dataStore.CloseHour.Second(), 0,
			loc,
		)

		// Handle toko yang tutuup tengah malam
		if closeTime.Before(openTime) {
			closeTime = closeTime.Add(24 * time.Hour)
		}

		isWithinOperationalHours := !now.Before(openTime) && !now.After(closeTime)
		if isWithinOperationalHours {
			return dto.CloseCashSessionResponse{}, errors.New("Toko masih dalam operasional tidak dapat menutup kas.")
		}
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
		status = dto.StatusShort
	} else if amountDifference.IsPositive() {
		status = dto.StatusOver
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
		"closed_at":     time.Now().In(loc),
	}

	var errCashNotFound = errors.New("Pembukuan tidak ditemukan, atau telah ditutup.")
	var errStoreNotFound = errors.New("Toko tidak ditemukan.")
	err = s.db.Transaction(func(tx *gorm.DB) error {
		rowsAffected, err := s.cashSessionRepo.Updates(updates, scopes...)
		if err != nil {
			return err
		}

		if rowsAffected == 0 {
			return errCashNotFound
		}

		storeUpdates := map[string]interface{}{
			"status": entity.StoreStatusClose,
		}

		rowsAffected, err = s.storeRepo.Updates(tx, storeUpdates, dataStore.ID)
		if err != nil {
			return err
		}

		if rowsAffected == 0 {
			return errStoreNotFound
		}

		return nil
	})

	if err != nil {
		if errors.Is(err, errCashNotFound) {
			return dto.CloseCashSessionResponse{}, err
		}

		if errors.Is(err, errStoreNotFound) {
			return dto.CloseCashSessionResponse{}, err
		}

		helper.Logger("close cash session and store", filePath, err)
		return dto.CloseCashSessionResponse{}, errors.New(BASE_MESSAGE)
	}

	return dto.CloseCashSessionResponse{
		AmountDifference: amountDifference,
		Status:           status,
	}, nil
}

func (s *cashSessionService) GetHistory(claims *lib.CustomClaims, req dto.HistoryCashSessionReq) ([]dto.HistoryCashSessionRes, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan mengambil data."
	_, filePath, _, _ := runtime.Caller(0)

	// Jika admin
	if claims.Role == entity.RoleAdmin {
		if req.IdStore == nil {
			return []dto.HistoryCashSessionRes{}, dto.ResponsePagination{}, errors.New("Id toko wajib diisi.")
		}

		idStore, err := uuid.Parse(*req.IdStore)
		if err != nil {
			return []dto.HistoryCashSessionRes{}, dto.ResponsePagination{}, errors.New("Id toko tidak valid.")
		}

		return s.getHistoryCashStore(req, idStore)
	}

	dataStaff, err := s.staffRepo.FindOne("id = ?", claims.UserId)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return []dto.HistoryCashSessionRes{}, dto.ResponsePagination{}, errors.New("Data staff tidak dapat ditemukan.")
		}

		helper.Logger("find one data staff", filePath, err)
		return []dto.HistoryCashSessionRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	if dataStaff.IdStore == nil {
		return []dto.HistoryCashSessionRes{}, dto.ResponsePagination{}, errors.New("Anda tidak memiliki akses. Mohon login ulang.")
	}

	return s.getHistoryCashStore(req, *dataStaff.IdStore)
}

func (s *cashSessionService) getHistoryCashStore(req dto.HistoryCashSessionReq, idStore uuid.UUID) ([]dto.HistoryCashSessionRes, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan mengambil data."
	_, filePath, _, _ := runtime.Caller(0)
	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return []dto.HistoryCashSessionRes{}, dto.ResponsePagination{}, errors.New("Toko tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("find data store", filePath, err)
		return []dto.HistoryCashSessionRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	var scopes []func(*gorm.DB) *gorm.DB
	if req.Query != nil {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			q := "%" + *req.Query + "%"
			return d.
				Joins("JOIN staff ON staff.id = cash_session.id_staff").
				Where("staff.name ILIKE ?", q)
		})
	}

	targetDate := time.Now()
	if req.Date != nil {
		targetDate = *req.Date
	}

	year, month, _ := targetDate.Date()
	startOfMonth := time.Date(year, month, 1, 0, 0, 0, 0, targetDate.Location())
	endOfMonth := startOfMonth.AddDate(0, 1, 0)

	var page = 1
	var limit = 6
	var orderBy = dto.OrderDesc
	if req.Page != nil {
		page = *req.Page
	}

	if req.Limit != nil {
		limit = *req.Limit
	}

	if req.OrderBy != nil {
		orderBy = *req.OrderBy
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.
			Where("created_at >= ? AND created_at < ?", startOfMonth, endOfMonth).
			Where("id_store = ?", idStore).
			Where("status = ?", entity.SessionClosed)
	})

	totalData, err := s.cashSessionRepo.Count(scopes...)
	if err != nil {
		helper.Logger("count total session", filePath, err)
		return []dto.HistoryCashSessionRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Clauses(clause.OrderBy{
			Columns: []clause.OrderByColumn{
				{Column: clause.Column{Name: "created_at"}, Desc: orderBy == dto.OrderDesc},
			},
		}).Offset((page - 1) * limit).Limit(limit)
	})

	paginationData := helper.GetPaginationData(page, limit, int(totalData))

	cashSessions, err := s.cashSessionRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("find all cash sessions", filePath, err)
		return []dto.HistoryCashSessionRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	var dataResult = make([]dto.HistoryCashSessionRes, 0, len(cashSessions))
	for _, c := range cashSessions {
		var totalIncomeCash decimal.Decimal
		var totalIncomeCashless decimal.Decimal
		var totalOutcome decimal.Decimal

		for _, t := range c.Transactions {
			if t.DeletedAt == nil {
				if t.TransactionType == entity.TransactionIncome {
					if t.PaymentType == entity.PaymentCash {
						totalIncomeCash = totalIncomeCash.Add(t.Amount)
					} else {
						totalIncomeCashless = totalIncomeCashless.Add(t.Amount)
					}
				} else {
					totalOutcome = totalOutcome.Add(t.Amount)
				}
			}
		}

		var amountActual decimal.Decimal
		if c.AmountActual != nil {
			amountActual = *c.AmountActual
		}

		totalIncome := totalIncomeCash.Add(totalIncomeCashless)
		totalAmount := totalIncome.Sub(totalOutcome).Add(c.SaldoBegin)

		amountDifference := amountActual.Sub(totalAmount)
		var status dto.StatusCloseCash
		if amountDifference.IsNegative() {
			status = dto.StatusShort
		} else if amountDifference.IsPositive() {
			status = dto.StatusOver
		} else {
			status = dto.StatusBalance
		}

		dataResult = append(dataResult, dto.HistoryCashSessionRes{
			IdCashSession:       c.ID,
			SaldoBegin:          c.SaldoBegin,
			AmountActual:        amountActual,
			AmountDifference:    amountDifference,
			TotalIncomeCash:     totalIncomeCash,
			TotalIncomeCashless: totalIncomeCashless,
			TotalOutcome:        totalOutcome,
			Status:              status,
			CreatedAt:           c.CreatedAt,
			ClosedAt:            c.ClosedAt,
			Store: dto.CashSessionStore{
				Id:        idStore,
				Name:      dataStore.Name,
				CloseHour: dataStore.CloseHour,
				OpenHour:  dataStore.OpenHour,
			},
			Staff: dto.CashSessionStaff{
				Id:   c.Staff.ID,
				Name: c.Staff.Name,
			},
		})
	}

	return dataResult, paginationData, nil
}
