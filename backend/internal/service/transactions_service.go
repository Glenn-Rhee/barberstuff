package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/repository"
	"errors"
	"runtime"
	"strings"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

type TransactionsService interface {
	CreateTransaction(req dto.CreateTransactionReq) error
}

type transactionsService struct {
	cashSessionRepo repository.CashSessionRepository
	transactionRepo repository.TransactionsRepository
	bookingRepo     repository.BookingRepository
	customerRepo    repository.CustomerRepository
	db              *gorm.DB
}

func NewTransactionsService(
	csr repository.CashSessionRepository,
	tr repository.TransactionsRepository,
	br repository.BookingRepository,
	cr repository.CustomerRepository,
	db *gorm.DB,
) TransactionsService {
	return &transactionsService{cashSessionRepo: csr, transactionRepo: tr, bookingRepo: br, db: db, customerRepo: cr}
}

func (s *transactionsService) CreateTransaction(req dto.CreateTransactionReq) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat saldo awal!"
	_, filePath, _, _ := runtime.Caller(0)

	idCashSession, err := uuid.Parse(req.IDCashSession)
	if err != nil {
		return errors.New("Id buku kasir tidak valid.")
	}

	_, err = s.cashSessionRepo.FindOne("id = ? AND status = ?", idCashSession, entity.SessionOpen)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Pembukuan tidak ditemukan atau telah ditutup.")
		}

		helper.Logger("find one cash session", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if req.TransactionType == entity.TransactionIncome {
		return s.createIncome(req, idCashSession)
	} else {
		return s.createOutcome(req, idCashSession)
	}
}

func (s *transactionsService) createIncome(req dto.CreateTransactionReq, idCashSession uuid.UUID) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat transaksi!"
	_, filePath, _, _ := runtime.Caller(0)

	// Handle Income
	if req.IdBooking == nil || req.PaymentType == nil {
		return errors.New("Id booking dan tipe pembayaran wajib diisi.")
	}

	idBooking, err := uuid.Parse(*req.IdBooking)
	if err != nil {
		return errors.New("Id booking tidak valid.")
	}

	dataBooking, err := s.bookingRepo.FindOne("id = ? AND status_booking = ?", idBooking, entity.BookingStatusProgress)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Booking telah selesai atau belum melakukan checkin.")
		}

		helper.Logger("find one booking", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	names := make([]string, len(dataBooking.BookingItems))
	for i, v := range dataBooking.BookingItems {
		names[i] = v.Service.Name
	}
	title := strings.Join(names, " + ")

	updatesVal := map[string]interface{}{
		"status_booking": entity.BookingStatusCompleted,
	}

	transactionAmount := dataBooking.TotalPrice

	if req.DiscountAmount != nil {
		if *req.DiscountAmount < 0 {
			return errors.New("Diskon tidak dapat berupa minus")
		}

		disCountAmount := decimal.NewFromFloat(*req.DiscountAmount)
		if disCountAmount.GreaterThan(dataBooking.TotalPrice) {
			return errors.New("Diskon tidak dapat melebihi sub total transaksi.")
		}

		
		updatesVal["discount_amount"] = disCountAmount
		newTotalPrice := gorm.Expr("total_price - ?", disCountAmount)
		updatesVal["total_price"] = newTotalPrice

		transactionAmount = dataBooking.TotalPrice.Sub(disCountAmount)
	}

	newTransaction := entity.Transactions{
		ID:              uuid.New(),
		IDCashSession:   idCashSession,
		Title:           title,
		PaymentType:     *req.PaymentType,
		Amount:          transactionAmount,
		TransactionType: entity.TransactionIncome,
		Description:     req.Description,
	}

	err = s.db.Transaction(func(tx *gorm.DB) error {
		pointCustomer := newTransaction.Amount.
			Div(decimal.NewFromInt(10000)).
			Floor().
			IntPart()

		rowsAffected, err := s.customerRepo.AddMemberPoints(tx, dataBooking.IDCustomer, int(pointCustomer))
		if err != nil {
			return errors.New(BASE_MESSAGE)
		}

		var scopes []func(*gorm.DB) *gorm.DB
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("id = ? AND status_booking = ?", idBooking, entity.BookingStatusProgress)
		})

		rowsAffected, err = s.bookingRepo.Updates(tx, updatesVal, scopes...)
		if err != nil {
			helper.Logger("update booking", filePath, err)
			return errors.New(BASE_MESSAGE)
		}
		if rowsAffected == 0 {
			return errors.New("Booking tidak ditemukan atau telah selesai.")
		}

		if err := s.transactionRepo.Create(tx, &newTransaction); err != nil {
			helper.Logger("Create transactions", filePath, err)
			return errors.New(BASE_MESSAGE)
		}

		return nil
	})

	if err != nil {
		helper.Logger("commit transaction", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return err
}

func (s *transactionsService) createOutcome(req dto.CreateTransactionReq, idCashSession uuid.UUID) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat saldo awal!"
	_, filePath, _, _ := runtime.Caller(0)

	if req.Title == nil || req.Amount == nil {
		return errors.New("Judul dan total pengeluaran wajib diisi.")
	}

	err := s.db.Transaction(func(tx *gorm.DB) error {
		newTransaction := entity.Transactions{
			ID:              uuid.New(),
			IDCashSession:   idCashSession,
			Title:           *req.Title,
			PaymentType:     entity.PaymentCashless,
			Amount:          decimal.NewFromFloat(*req.Amount),
			TransactionType: entity.TransactionOutcome,
			Description:     req.Description,
		}

		err := s.transactionRepo.Create(tx, &newTransaction)
		return err
	})

	if err != nil {
		helper.Logger("create new transactions", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
