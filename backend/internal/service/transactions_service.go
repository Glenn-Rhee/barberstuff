package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"errors"
	"runtime"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

type TransactionsService interface {
	CreateTransaction(req dto.CreateTransactionReq) error
	VoidTransaction(claims *lib.CustomClaims, req dto.VoidTransactionReq) error
}

type transactionsService struct {
	cashSessionRepo repository.CashSessionRepository
	transactionRepo repository.TransactionsRepository
	bookingRepo     repository.BookingRepository
	customerRepo    repository.CustomerRepository
	staffRepo       repository.StaffRepository
	db              *gorm.DB
}

func NewTransactionsService(
	csr repository.CashSessionRepository,
	tr repository.TransactionsRepository,
	br repository.BookingRepository,
	cr repository.CustomerRepository,
	sr repository.StaffRepository,
	db *gorm.DB,
) TransactionsService {
	return &transactionsService{
		cashSessionRepo: csr,
		transactionRepo: tr,
		bookingRepo:     br,
		db:              db,
		customerRepo:    cr,
		staffRepo:       sr,
	}
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

func (s *transactionsService) VoidTransaction(claims *lib.CustomClaims, req dto.VoidTransactionReq) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat saldo awal!"
	_, filePath, _, _ := runtime.Caller(0)

	idStaff, err := uuid.Parse(claims.UserId)
	if err != nil {
		return errors.New("Data akun anda tidak valid. Mohon login ulang.")
	}

	dataStaff, err := s.staffRepo.FindOne("id = ? AND id_store IS NOT NULL", idStaff)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Data anda tidak valid. Mohon login ulang.")
		}

		helper.Logger("find one staff", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if dataStaff.IdStore == nil {
		return errors.New("Anda tidak memiliki akses.")
	}

	idTransaction, err := uuid.Parse(req.IdTransaction)
	if err != nil {
		return errors.New("Id transaksi tidak valid.")
	}

	dataTransaction, err := s.transactionRepo.FindOne("id = ?", idTransaction)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Transaksi tidak ditemukan atau telah di batalkan.")
		}

		helper.Logger("find one transaksi", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	dataCashSession, err := s.cashSessionRepo.FindOne("id = ?", dataTransaction.IDCashSession)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Pembukuan tidak ditemukan.")
		}

		helper.Logger("find one cash session", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if dataCashSession.IDStore != *dataStaff.IdStore {
		return errors.New("Anda tidak dapat membatalkan pesanan milik toko lain.")
	}

	var (
		errTransactionNotFound = errors.New("Transaksi tidak ditemukan.")
		errBookingNotFound     = errors.New("Booking not found.")
	)
	err = s.db.Transaction(func(tx *gorm.DB) error {
		updatesTransactions := map[string]interface{}{
			"deleted_at":  time.Now(),
			"description": req.Description,
		}

		var scopesTransactions []func(*gorm.DB) *gorm.DB
		scopesTransactions = append(scopesTransactions, func(d *gorm.DB) *gorm.DB {
			return d.
				Where("id = ?", idTransaction).
				Where("id_cash_session = ?", dataCashSession.ID).
				Where("deleted_at IS NULL")
		})

		rowsAffected, err := s.transactionRepo.Updates(tx, updatesTransactions, scopesTransactions...)
		if err != nil {
			return err
		}

		if rowsAffected == 0 {
			return errTransactionNotFound
		}

		if dataTransaction.IDBooking == nil {
			return nil
		}

		updatesBooking := map[string]interface{}{
			"status_booking": entity.BookingStatusCanceled,
			"notes":          req.Description,
		}

		var scopesBooking []func(*gorm.DB) *gorm.DB
		scopesBooking = append(scopesBooking, func(d *gorm.DB) *gorm.DB {
			return d.
				Where("id = ?", dataTransaction.IDBooking).
				Where("id_store = ?", dataStaff.IdStore).
				Where("status_booking = ?", entity.BookingStatusCompleted)
		})

		rowsAffected, err = s.bookingRepo.Updates(tx, updatesBooking, scopesBooking...)
		if err != nil {
			return err
		}

		if rowsAffected == 0 {
			return errBookingNotFound
		}

		return nil
	})

	if err != nil {
		if errors.Is(err, errTransactionNotFound) {
			return errors.New("Transaksi tidak ditemukan atau telah di cancel.")
		}

		if errors.Is(err, errBookingNotFound) {
			return errors.New("Booking tidak ditemukan atau telah di cancel")
		}

		helper.Logger("soft delete transaction", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *transactionsService) createIncome(req dto.CreateTransactionReq, idCashSession uuid.UUID) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat transaksi!"
	_, filePath, _, _ := runtime.Caller(0)

	if req.PaymentType == nil {
		return errors.New("Tipe pembayaran wajib diisi.")
	}

	var titleTransactions string
	var transactionsAmount decimal.Decimal
	var transactionsIdBooking *uuid.UUID
	var dataBooking entity.Booking
	updatesVal := map[string]interface{}{
		"status_booking": entity.BookingStatusCompleted,
	}

	if req.IdBooking == nil {
		if req.Title == nil || req.Amount == nil {
			return errors.New("Judul dan jumlah uang masuk wajib diisi.")
		}
		if *req.Amount <= 0 {
			return errors.New("Jumlah uang masuk harus lebih dari 0.")
		}

		titleTransactions = *req.Title
		transactionsAmount = decimal.NewFromFloat(*req.Amount)
	} else {
		idBooking, err := uuid.Parse(*req.IdBooking)
		if err != nil {
			return errors.New("Id booking tidak valid.")
		}
		transactionsIdBooking = &idBooking

		dataBooking, err = s.bookingRepo.FindOne("id = ? AND status_booking = ?", idBooking, entity.BookingStatusProgress)
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
		titleTransactions = strings.Join(names, " + ")
		transactionsAmount = dataBooking.TotalPrice

		if req.DiscountAmount != nil {
			if *req.DiscountAmount < 0 {
				return errors.New("Diskon tidak dapat berupa minus")
			}
			discount := decimal.NewFromFloat(*req.DiscountAmount)
			if discount.GreaterThan(dataBooking.TotalPrice) {
				return errors.New("Diskon tidak dapat melebihi sub total transaksi.")
			}
			updatesVal["discount_amount"] = discount
			updatesVal["total_price"] = gorm.Expr("total_price - ?", discount)
			transactionsAmount = dataBooking.TotalPrice.Sub(discount)
		}
	}

	newTransaction := entity.Transactions{
		ID:              uuid.New(),
		IDCashSession:   idCashSession,
		Title:           titleTransactions,
		PaymentType:     *req.PaymentType,
		Amount:          transactionsAmount,
		TransactionType: entity.TransactionIncome,
		Description:     req.Description,
		IDBooking:       transactionsIdBooking,
	}

	var errBookingNotFound = errors.New("Booking tidak ditemukan atau telah selesai.")
	err := s.db.Transaction(func(tx *gorm.DB) error {
		// Hanya untuk transaksi yang berasal dari booking
		if transactionsIdBooking != nil {
			rowsAffected, err := s.bookingRepo.Updates(tx, updatesVal, func(d *gorm.DB) *gorm.DB {
				return d.Where("id = ? AND status_booking = ?", *transactionsIdBooking, entity.BookingStatusProgress)
			})
			if err != nil {
				helper.Logger("update booking", filePath, err)
				return errors.New(BASE_MESSAGE)
			}
			if rowsAffected == 0 {
				return errBookingNotFound
			}

			points := newTransaction.Amount.Div(decimal.NewFromInt(10000)).Floor().IntPart()
			rows, err := s.customerRepo.AddMemberPoints(tx, dataBooking.IDCustomer, int(points))
			if err != nil {
				helper.Logger("add member points", filePath, err)
				return errors.New(BASE_MESSAGE)
			}
			if rows == 0 {
				return errors.New("Customer tidak ditemukan.")
			}
		}

		if err := s.transactionRepo.Create(tx, &newTransaction); err != nil {
			helper.Logger("create transactions", filePath, err)
			return errors.New(BASE_MESSAGE)
		}
		return nil
	})

	if err != nil {
		// Error bisnis diteruskan apa adanya, selain itu pakai pesan umum
		if errors.Is(err, errBookingNotFound) {
			return err
		}
		return errors.New(BASE_MESSAGE)
	}
	
	return nil
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
