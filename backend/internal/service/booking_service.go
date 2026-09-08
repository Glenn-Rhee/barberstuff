package service

import (
	"barberstuff_backend/internal/constant"
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"context"
	"errors"
	"fmt"
	"runtime"
	"time"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

type BookingService interface {
	LockBooking(req dto.LockBookingRequest, claims *lib.CustomClaims, ctx context.Context) error
	CreateBooking(ctx context.Context, claims *lib.CustomClaims, req dto.CreateBookingRequest) (dto.CreateBookingResponse, error)
}

type bookingService struct {
	bookingRepo repository.BookingRepository
	client      *redis.Client
	capsterRepo repository.CapsterRepository
	storeRepo   repository.StoreRepository
	serviceRepo repository.ServiceRepository
	promoRepo   repository.PromoRepository
	db          *gorm.DB
}

func NewBookingService(
	br repository.BookingRepository,
	c *redis.Client,
	cr repository.CapsterRepository,
	sr repository.StoreRepository,
	srp repository.ServiceRepository,
	pr repository.PromoRepository,
	db *gorm.DB,
) BookingService {
	return &bookingService{
		bookingRepo: br,
		client:      c,
		capsterRepo: cr,
		storeRepo:   sr,
		serviceRepo: srp,
		promoRepo:   pr,
		db:          db,
	}
}

func (s *bookingService) LockBooking(req dto.LockBookingRequest, claims *lib.CustomClaims, ctx context.Context) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat booking"
	_, filePath, _, _ := runtime.Caller(0)

	now := time.Now()
	scheduledAt := req.BookingDate

	if scheduledAt.Before(now) {
		return errors.New("Tanggal dan jam booking tidak boleh kurang dari waktu sekarang.")
	}

	minimumBookingTime := now.Add(30 * time.Minute)
	if scheduledAt.Before(minimumBookingTime) {
		return errors.New("Booking minimal 30 menit dari sekarang.")
	}

	userId, err := uuid.Parse(claims.UserId)
	if err != nil {
		return errors.New("User tidak valid!")
	}

	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return errors.New("Toko tidak valid")
	}

	idCapster, err := uuid.Parse(req.IdCapster)
	if err != nil {
		return errors.New("Id capster tidak valid!")
	}

	_, err = s.capsterRepo.FindOne(&entity.Capster{ID: idCapster, Status: entity.CapsterStatusActive})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Capster tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("find one store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	// FIX: status yang dicek untuk "user masih punya booking aktif" adalah Booked & Progress
	// (sebelumnya pakai nama status lama Completed/Canceled yang tidak sesuai 4 status: booked, progress, done, cancel)
	_, err = s.bookingRepo.FindOne(
		"id_user = ? AND status_booking IN ?",
		userId,
		[]entity.BookingStatusEnum{entity.BookingStatusBooked, entity.BookingStatusProgress},
	)

	if err == nil {
		return errors.New("Anda telah memiliki booking! Tidak dapat booking kembali.")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find one data", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	dateSchedule := scheduledAt.Format("2006-01-02")
	timeSchedule := scheduledAt.Format("15:04")

	// Cek apakah jam yang di schedulekan itu berada di rentang store open dan store close
	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("find one store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	slots := helper.GenerateAvailableSlots(req.BookingDate, dataStore.OpenHour, dataStore.CloseHour)
	var isMatchWithSlotTime = false
	for _, v := range slots {
		timeSlot := v.Format("15:04")
		if timeSlot == timeSchedule {
			isMatchWithSlotTime = true
			break
		}
	}

	if !isMatchWithSlotTime {
		return errors.New("Jam booking tidak sesuai dengan jam tersedia.")
	}

	// Cek apakah user sudah lock booking
	userLockKey := fmt.Sprintf("user_lock:%v", userId)
	existingLock, err := s.client.Get(ctx, userLockKey).Result()
	if err == nil && existingLock != "" {
		return errors.New("Anda masih memiliki booking yang sedang diproses")
	}

	if err != nil && !errors.Is(err, redis.Nil) {
		helper.Logger("find existing user lock", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	// FIX: Cek 1 — sekarang filter berdasarkan scheduled_at (jam yang sama persis)
	// Sebelumnya tidak ada filter tanggal sama sekali, jadi menarik SEMUA booking ongoing
	// di toko itu tanpa peduli tanggal/jam, yang menyebabkan false positive.
	var scopeTime []func(*gorm.DB) *gorm.DB
	scopeTime = append(scopeTime, func(d *gorm.DB) *gorm.DB {
		return d.
			Where("id_store = ?", req.IdStore).
			Where("scheduled_at = ?", req.BookingDate).
			Where("status_booking IN ?", []entity.BookingStatusEnum{
				entity.BookingStatusBooked,
				entity.BookingStatusProgress,
			})
	})

	dataBookedTime, err := s.bookingRepo.FindAll(scopeTime...)
	if err != nil {
		helper.Logger("find all booking by time", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	// FIX: Cek 2 — baru, terpisah dari Cek 1. Menangkap kasus capster masih `progress`
	// dari booking SEBELUMNYA yang telat (beda jam), TANPA filter tanggal.
	// Hanya status `progress` yang dicek di sini (bukan `booked`), supaya tidak salah
	var scopeCapster []func(*gorm.DB) *gorm.DB
	scopeCapster = append(scopeCapster, func(d *gorm.DB) *gorm.DB {
		return d.
			Where("id_capster = ?", idCapster).
			Where("status_booking = ?", entity.BookingStatusProgress)
	})

	dataBookedCapster, err := s.bookingRepo.FindAll(scopeCapster...)
	if err != nil {
		helper.Logger("find all booking by capster", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	// FIX: cek kapasitas capster sekarang berdasarkan dataBookedTime (jam yang sama),
	// bukan dataBookedes lama yang tidak difilter tanggal.
	if len(dataBookedTime) > 0 {
		var scopes []func(*gorm.DB) *gorm.DB
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.
				Where("id_store = ?", req.IdStore).
				Where("status = ?", entity.CapsterStatusActive)
		})

		dataCapsters, err := s.capsterRepo.FindAll(scopes...)
		if err != nil {
			helper.Logger("find all capsters", filePath, err)
			return errors.New(BASE_MESSAGE)
		}

		if len(dataBookedTime) >= (len(dataCapsters) - 1) {
			return errors.New("Sudah tidak ada capster yang tersedia.")
		}
	}

	// FIX: hapus break di tengah loop supaya kedua kondisi dicek independen,
	// tidak saling menghentikan satu sama lain sebelum semua baris selesai dicek.
	var isTimeAvailable = true
	var isCapsterAvailable = true

	for _, v := range dataBookedTime {
		if v.ScheduledAt.Equal(req.BookingDate) {
			isTimeAvailable = false
		}
		if v.IDCapster == idCapster {
			isCapsterAvailable = false
		}
	}

	// FIX: tambahan pengecekan dari Cek 2 — capster masih progress dari booking lain
	if len(dataBookedCapster) > 0 {
		isCapsterAvailable = false
	}

	if !isTimeAvailable {
		return errors.New("Waktu booking ini sudah di booking!")
	}

	if !isCapsterAvailable {
		return errors.New("Capster ini sedang tidak tersedia.")
	}

	// Lock booking selama 5 menit
	bookingLockKey := fmt.Sprintf("lock:%v:%v:%v:%v", req.IdStore, dateSchedule, timeSchedule, req.IdCapster)
	ok, err := s.client.SetNX(ctx, bookingLockKey, userId.String(), 5*time.Minute).Result()
	if err != nil {
		helper.Logger("store lock booking", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if !ok {
		return errors.New("Slot ini sudah di kunci oleh orang lain.")
	}

	err = s.client.Set(ctx, userLockKey, bookingLockKey, 5*time.Minute).Err()
	if err != nil {
		s.client.Del(ctx, bookingLockKey)
		helper.Logger("store lock client", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *bookingService) CreateBooking(ctx context.Context, claims *lib.CustomClaims, req dto.CreateBookingRequest) (dto.CreateBookingResponse, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat booking. Coba lagi nanti!"
	_, filePath, _, _ := runtime.Caller(0)

	now := time.Now()
	scheduledAt := req.BookingDate
	dateSchedule := scheduledAt.Format("2006-01-02")
	timeSchedule := scheduledAt.Format("15:04")

	userId, err := uuid.Parse(claims.UserId)
	if err != nil {
		return dto.CreateBookingResponse{}, errors.New("User tidak valid!")
	}

	userLockKey := fmt.Sprintf("user_lock:%v", userId)
	_, err = s.client.Get(ctx, userLockKey).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return dto.CreateBookingResponse{}, errors.New("Anda belum melakukan lock booking! Mohon untuk lock booking terlebih dahulu!")
		}

		helper.Logger("Get user lock key", filePath, err)
		return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
	}

	bookingLockKey := fmt.Sprintf("lock:%v:%v:%v:%v", req.IdStore, dateSchedule, timeSchedule, req.IdCapster)
	val, err := s.client.Get(ctx, bookingLockKey).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return dto.CreateBookingResponse{}, errors.New("Data Booking tidak ditemukan atau waktu booking telah habis!")
		}

		helper.Logger("Get booking lock key", filePath, err)
		return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
	}

	userIdBooked, err := uuid.Parse(val)
	if err != nil {
		return dto.CreateBookingResponse{}, errors.New("Data tidak valid!")
	}

	if userIdBooked != userId {
		return dto.CreateBookingResponse{}, errors.New("Data booking ini bukan milik anda!")
	}

	if scheduledAt.Before(now) {
		return dto.CreateBookingResponse{}, errors.New("Tanggal dan jam booking tidak boleh kurang dari waktu sekarang.")
	}

	minimumBookingTime := now.Add(30 * time.Minute)
	if scheduledAt.Before(minimumBookingTime) {
		return dto.CreateBookingResponse{}, errors.New("Booking minimal 30 menit dari sekarang.")
	}

	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return dto.CreateBookingResponse{}, errors.New("Toko tidak valid")
	}

	idCapster, err := uuid.Parse(req.IdCapster)
	if err != nil {
		return dto.CreateBookingResponse{}, errors.New("Id capster tidak valid!")
	}

	dataCapster, err := s.capsterRepo.FindOne(&entity.Capster{ID: idCapster, Status: entity.CapsterStatusActive})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.CreateBookingResponse{}, errors.New("Capster tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("find one store", filePath, err)
		return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
	}

	_, err = s.bookingRepo.FindOne(
		"id_user = ? AND status_booking IN ?",
		userId,
		[]entity.BookingStatusEnum{entity.BookingStatusBooked, entity.BookingStatusProgress},
	)

	if err == nil {
		return dto.CreateBookingResponse{}, errors.New("Anda telah memiliki booking! Tidak dapat booking kembali.")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find one data", filePath, err)
		return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
	}

	// Cek apakah jam yang di schedulekan itu berada di rentang store open dan store close
	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.CreateBookingResponse{}, errors.New("Toko tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("find one store", filePath, err)
		return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
	}

	slots := helper.GenerateAvailableSlots(req.BookingDate, dataStore.OpenHour, dataStore.CloseHour)
	var isMatchWithSlotTime = false
	for _, v := range slots {
		timeSlot := v.Format("15:04")
		if timeSlot == timeSchedule {
			isMatchWithSlotTime = true
			break
		}
	}

	if !isMatchWithSlotTime {
		return dto.CreateBookingResponse{}, errors.New("Jam booking tidak sesuai dengan jam tersedia.")
	}

	// FIX: Cek 1 — sekarang filter berdasarkan scheduled_at (jam yang sama persis)
	// Sebelumnya tidak ada filter tanggal sama sekali, jadi menarik SEMUA booking ongoing
	// di toko itu tanpa peduli tanggal/jam, yang menyebabkan false positive.
	var scopeTime []func(*gorm.DB) *gorm.DB
	scopeTime = append(scopeTime, func(d *gorm.DB) *gorm.DB {
		return d.
			Where("id_store = ?", req.IdStore).
			Where("scheduled_at = ?", req.BookingDate).
			Where("status_booking IN ?", []entity.BookingStatusEnum{
				entity.BookingStatusBooked,
				entity.BookingStatusProgress,
			})
	})

	dataBookedTime, err := s.bookingRepo.FindAll(scopeTime...)
	if err != nil {
		helper.Logger("find all booking by time", filePath, err)
		return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
	}

	var scopeCapster []func(*gorm.DB) *gorm.DB
	scopeCapster = append(scopeCapster, func(d *gorm.DB) *gorm.DB {
		return d.
			Where("id_capster = ?", idCapster).
			Where("status_booking = ?", entity.BookingStatusProgress)
	})

	dataBookedCapster, err := s.bookingRepo.FindAll(scopeCapster...)
	if err != nil {
		helper.Logger("find all booking by capster", filePath, err)
		return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
	}

	// FIX: cek kapasitas capster sekarang berdasarkan dataBookedTime (jam yang sama),
	// bukan dataBookedes lama yang tidak difilter tanggal.
	if len(dataBookedTime) > 0 {
		var scopes []func(*gorm.DB) *gorm.DB
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.
				Where("id_store = ?", req.IdStore).
				Where("status = ?", entity.CapsterStatusActive)
		})

		dataCapsters, err := s.capsterRepo.FindAll(scopes...)
		if err != nil {
			helper.Logger("find all capsters", filePath, err)
			return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
		}

		if len(dataBookedTime) >= (len(dataCapsters) - 1) {
			return dto.CreateBookingResponse{}, errors.New("Sudah tidak ada capster yang tersedia.")
		}
	}

	// FIX: hapus break di tengah loop supaya kedua kondisi dicek independen,
	// tidak saling menghentikan satu sama lain sebelum semua baris selesai dicek.
	var isTimeAvailable = true
	var isCapsterAvailable = true

	for _, v := range dataBookedTime {
		if v.ScheduledAt.Equal(req.BookingDate) {
			isTimeAvailable = false
		}
		if v.IDCapster == idCapster {
			isCapsterAvailable = false
		}
	}

	// FIX: tambahan pengecekan dari Cek 2 — capster masih progress dari booking lain
	if len(dataBookedCapster) > 0 {
		isCapsterAvailable = false
	}

	if !isTimeAvailable {
		return dto.CreateBookingResponse{}, errors.New("Waktu booking ini sudah di booking!")
	}

	if !isCapsterAvailable {
		return dto.CreateBookingResponse{}, errors.New("Capster ini sedang tidak tersedia.")
	}

	IdService, err := uuid.Parse(req.IdService)
	if err != nil {
		return dto.CreateBookingResponse{}, errors.New("Data Service tidak valid!")
	}

	dataService, err := s.serviceRepo.FindOne("id = ?", IdService)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.CreateBookingResponse{}, errors.New("Service tidak ditemukan! Atau telah dihapus")
		}

		helper.Logger("find data service", filePath, err)
		return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
	}

	if dataService.Status == entity.ProductStatusInactive {
		return dto.CreateBookingResponse{}, errors.New("Service ini telah tidak tersedia! Mohon pilih ulang.")
	}

	var subTotal = dataService.Price // tetap decimal.Decimal
	var discountAmount = decimal.Zero
	var totalPrice = subTotal
	if req.IdPromoClaimed != nil {
		dataPromo, err := s.promoRepo.FindOne("id = ?", req.IdPromoClaimed)
		if err == nil {
			if dataPromo.IsUsed {
				return dto.CreateBookingResponse{}, errors.New("Promo ini telah digunakan")
			}

			if dataPromo.Promo.Status != entity.PromoStatusVisible {
				return dto.CreateBookingResponse{}, errors.New("Promo ini sudah tidak berlaku!")
			}

			if dataPromo.Promo.ExpiredAt != nil && dataPromo.Promo.ExpiredAt.Before(time.Now()) {
				return dto.CreateBookingResponse{}, errors.New("Promo ini sudah kedaluwarsa!")
			}

			if dataPromo.Promo.DiscountType == entity.DiscountTypeFixed {
				discountAmount = dataPromo.Promo.DiscountValue
			} else {
				// percentage: value 0-100, jadi dibagi 100
				discountAmount = subTotal.Mul(dataPromo.Promo.DiscountValue).Div(decimal.NewFromInt(100))
			}

			if discountAmount.GreaterThan(subTotal) {
				discountAmount = subTotal
			}

			totalPrice = subTotal.Sub(discountAmount)
		}

		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return dto.CreateBookingResponse{}, errors.New("Promo Anda tidak ditemukan")
			}

			helper.Logger("find data promo", filePath, err)
			return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
		}
	}

	totalPrice = decimal.NewFromInt(constant.APP_SERVICE_FEE).Add(totalPrice)

	idBooking := uuid.New()
	bookingItems := []entity.BookingItem{{
		ID:          uuid.New(),
		IDBooking:   idBooking,
		IDService:   IdService,
		Price:       dataService.Price,
		AddedOnSpot: false,
	}}

	var idPromoClaimed *uuid.UUID = nil
	if req.IdPromoClaimed != nil {
		parsed, err := uuid.Parse(*req.IdPromoClaimed)
		if err != nil {
			return dto.CreateBookingResponse{}, errors.New("Promo tidak valid")
		}

		idPromoClaimed = &parsed
	}
	qrCode := fmt.Sprintf("bk%v", idBooking)
	data := entity.Booking{
		ID:             idBooking,
		StatusBooking:  entity.BookingStatusBooked,
		IDStore:        idStore,
		IDUser:         userId,
		IDCapster:      idCapster,
		IDPromoClaimed: idPromoClaimed,
		SubTotal:       subTotal,
		DiscountAmount: discountAmount,
		TotalPrice:     totalPrice,
		ScheduledAt:    scheduledAt,
		QRCode:         qrCode,
		BookingType:    entity.BookingScheduled,
		BookingItems:   bookingItems,
	}

	err = s.db.Transaction(func(tx *gorm.DB) error {
		return s.bookingRepo.Create(tx, &data)
	})

	if err != nil {
		helper.Logger("createe data booking", filePath, err)
		return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
	}

	s.client.Del(ctx, bookingLockKey)
	s.client.Del(ctx, userLockKey)

	result := dto.CreateBookingResponse{
		IdBooking:   idBooking,
		QrCode:      qrCode,
		BookingDate: scheduledAt,
		TotalPrice:  totalPrice,
		Store: dto.DataStoreBooking{
			Id:          idStore,
			Name:        dataStore.Name,
			Address:     *dataStore.Address,
			PhoneNumber: *dataStore.PhoneNumber,
		},
		Capster: dto.DataCapsterBooking{
			Id:   idCapster,
			Name: dataCapster.Name,
		},
		Service: []dto.DataServiceBooking{{
			Id:    IdService,
			Name:  dataService.Name,
			Price: dataService.Price,
		}},
		AppServiceFee: constant.APP_SERVICE_FEE,
	}

	return result, nil
}
