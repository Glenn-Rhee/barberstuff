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
	"gorm.io/gorm/clause"
)

type BookingService interface {
	LockBooking(req dto.LockBookingRequest, claims *lib.CustomClaims, ctx context.Context) error
	CreateBooking(ctx context.Context, claims *lib.CustomClaims, req dto.CreateBookingRequest) (dto.CreateBookingResponse, error)
	GetBookingStore(ctx context.Context, claims *lib.CustomClaims, reqParams dto.GetBookingStoreRequest) (dto.GetBookingStoreResponse, error)
	DeleteLockBooking(ctx context.Context, claims *lib.CustomClaims, reqParams dto.DeleteLockBookingRequest) error
	GetBookingUser(claims *lib.CustomClaims, reqParams dto.GetBookingUserRequest) ([]dto.GetBookingUserResponse, dto.ResponsePagination, error)
	AutoCancelBookings(ctx context.Context) error
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

	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return errors.New("Toko tidak valid")
	}

	idCapster, err := uuid.Parse(req.IdCapster)
	if err != nil {
		return errors.New("Id capster tidak valid!")
	}

	// FIX: dataStore dipindah ke atas, karena Timezone-nya dibutuhkan sebelum pengecekan waktu
	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("find one store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	// FIX: load lokasi toko dari dataStore.Timezone
	loc, err := time.LoadLocation(string(dataStore.Timezone))
	if err != nil {
		helper.Logger("load timezone", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	now := time.Now().In(loc)              // FIX: convert ke lokasi toko
	scheduledAt := req.BookingDate.In(loc) // FIX: convert ke lokasi toko

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

	dataCapster, err := s.capsterRepo.FindOne(&entity.Capster{ID: idCapster, Status: entity.CapsterStatusActive})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Capster tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("find one store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if dataCapster.IDStore != idStore {
		return errors.New("Capster ini bukan merupakan bagian dari toko yang anda pilih!")
	}

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

	dateSchedule := scheduledAt.Format("2006-01-02") // sudah otomatis benar karena scheduledAt sudah di-convert
	timeSchedule := scheduledAt.Format("15:04")      // sudah otomatis benar karena scheduledAt sudah di-convert

	slots := helper.GenerateAvailableSlots(req.BookingDate, dataStore.OpenHour, dataStore.CloseHour, loc) // FIX: tambah parameter loc
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

	userLockKey := fmt.Sprintf("user_lock:%v", userId)
	existingLock, err := s.client.Get(ctx, userLockKey).Result()
	if err == nil && existingLock != "" {
		return errors.New("Anda masih memiliki booking yang sedang diproses")
	}

	if err != nil && !errors.Is(err, redis.Nil) {
		helper.Logger("find existing user lock", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	var scopeTime []func(*gorm.DB) *gorm.DB
	scopeTime = append(scopeTime, func(d *gorm.DB) *gorm.DB {
		return d.
			Where("id_store = ?", req.IdStore).
			Where("scheduled_at = ?", scheduledAt). // FIX: pakai scheduledAt yang sudah di-convert
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

	var isTimeAvailable = true
	var isCapsterAvailable = true

	for _, v := range dataBookedTime {
		if v.ScheduledAt.In(loc).Equal(scheduledAt) { // FIX: convert v.ScheduledAt ke loc sebelum compare
			isTimeAvailable = false
		}
		if v.IDCapster == idCapster {
			isCapsterAvailable = false
		}
	}

	if len(dataBookedCapster) > 0 {
		isCapsterAvailable = false
	}

	if !isTimeAvailable {
		return errors.New("Waktu booking ini sudah di booking!")
	}

	if !isCapsterAvailable {
		return errors.New("Capster ini sedang tidak tersedia.")
	}

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

	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return dto.CreateBookingResponse{}, errors.New("Toko tidak valid")
	}

	idCapster, err := uuid.Parse(req.IdCapster)
	if err != nil {
		return dto.CreateBookingResponse{}, errors.New("Id capster tidak valid!")
	}

	// FIX: dataStore dipindah ke atas, karena Timezone-nya dibutuhkan sebelum pengecekan waktu
	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.CreateBookingResponse{}, errors.New("Toko tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("find one store", filePath, err)
		return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
	}

	// FIX: load lokasi toko dari dataStore.Timezone
	loc, err := time.LoadLocation(string(dataStore.Timezone))
	if err != nil {
		helper.Logger("load timezone", filePath, err)
		return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
	}

	now := time.Now().In(loc)              // FIX: convert ke lokasi toko
	scheduledAt := req.BookingDate.In(loc) // FIX: convert ke lokasi toko
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

	dataCapster, err := s.capsterRepo.FindOne(&entity.Capster{ID: idCapster, Status: entity.CapsterStatusActive})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.CreateBookingResponse{}, errors.New("Capster tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("find one store", filePath, err)
		return dto.CreateBookingResponse{}, errors.New(BASE_MESSAGE)
	}

	if dataCapster.IDStore != idStore {
		return dto.CreateBookingResponse{}, errors.New("Capster ini bukan merupakan bagian dari toko yang anda pilih!")
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

	slots := helper.GenerateAvailableSlots(req.BookingDate, dataStore.OpenHour, dataStore.CloseHour, loc) // FIX: tambah parameter loc
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

	var scopeTime []func(*gorm.DB) *gorm.DB
	scopeTime = append(scopeTime, func(d *gorm.DB) *gorm.DB {
		return d.
			Where("id_store = ?", req.IdStore).
			Where("scheduled_at = ?", scheduledAt). // FIX: pakai scheduledAt yang sudah di-convert
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

	var isTimeAvailable = true
	var isCapsterAvailable = true

	for _, v := range dataBookedTime {
		if v.ScheduledAt.In(loc).Equal(scheduledAt) { // FIX: convert v.ScheduledAt ke loc sebelum compare
			isTimeAvailable = false
		}
		if v.IDCapster == idCapster {
			isCapsterAvailable = false
		}
	}

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

	if dataService.IdStore != idStore {
		return dto.CreateBookingResponse{}, errors.New("Toko ini tidak memiliki service tersebut.")
	}

	if dataService.Status == entity.ProductStatusInactive {
		return dto.CreateBookingResponse{}, errors.New("Service ini telah tidak tersedia! Mohon pilih ulang.")
	}

	var subTotal = dataService.Price
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
		ScheduledAt:    scheduledAt, // sudah otomatis benar karena scheduledAt sudah di-convert
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
			Address:     dataStore.Address,
			PhoneNumber: dataStore.PhoneNumber,
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

func (s *bookingService) GetBookingStore(ctx context.Context, claims *lib.CustomClaims, req dto.GetBookingStoreRequest) (dto.GetBookingStoreResponse, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil booking toko. Coba lagi nanti!"
	_, filePath, _, _ := runtime.Caller(0)

	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return dto.GetBookingStoreResponse{}, errors.New("Data toko tidak valid!")
	}

	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.GetBookingStoreResponse{}, errors.New("Data toko tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("Find data store", filePath, err)
		return dto.GetBookingStoreResponse{}, errors.New(BASE_MESSAGE)
	}

	// FIX: load lokasi toko dari dataStore.Timezone (bukan hardcode Asia/Jakarta lagi)
	loc, err := time.LoadLocation(string(dataStore.Timezone))
	if err != nil {
		helper.Logger("load timezone", filePath, err)
		return dto.GetBookingStoreResponse{}, errors.New(BASE_MESSAGE)
	}

	reqDateLocal := req.Date.In(loc) // FIX: convert tanggal request ke lokasi toko

	slots := helper.GenerateAvailableSlots(req.Date, dataStore.OpenHour, dataStore.CloseHour, loc) // FIX: tambah parameter loc
	slotStrings := make([]string, len(slots))
	for i, slot := range slots {
		slotStrings[i] = slot.Format("15:04")
	}

	var scopes []func(*gorm.DB) *gorm.DB
	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Where("id_store = ?", idStore).
			Where("status = ?", entity.CapsterStatusActive)
	})

	dataCapsters, err := s.capsterRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("Find all data capsters", filePath, err)
		return dto.GetBookingStoreResponse{}, errors.New(BASE_MESSAGE)
	}

	capsterIds := make([]string, len(dataCapsters))
	for i, c := range dataCapsters {
		capsterIds[i] = c.ID.String()
	}

	var scopesBooked []func(d *gorm.DB) *gorm.DB
	scopesBooked = append(scopesBooked, func(d *gorm.DB) *gorm.DB {
		startDay := time.Date(reqDateLocal.Year(), reqDateLocal.Month(), reqDateLocal.Day(), 0, 0, 0, 0, loc) // FIX: pakai reqDateLocal & loc
		endOfDay := startDay.Add(24 * time.Hour)

		return d.Where("id_store = ?", idStore).
			Where("scheduled_at >= ? AND scheduled_at < ?", startDay, endOfDay)
	})

	dataBooked, err := s.bookingRepo.FindAll(scopesBooked...)

	// FIX: loc dihapus dari sini, pakai loc yang sudah di-load dari dataStore.Timezone di atas
	dbBookedMap := make(map[string]bool)
	for _, b := range dataBooked {
		key := fmt.Sprintf("%s|%s", b.ScheduledAt.In(loc).Format("15:04"), b.IDCapster.String())
		dbBookedMap[key] = true
	}

	pipe := s.client.Pipeline()
	cmdMap := make(map[string]*redis.StringCmd)

	for _, timeStr := range slotStrings {
		for _, capsterId := range capsterIds {
			key := fmt.Sprintf("lock:%s:%s:%s:%s", idStore, reqDateLocal.Format("2006-01-02"), timeStr, capsterId) // FIX: pakai reqDateLocal
			cmdMap[fmt.Sprintf("%s|%s", timeStr, capsterId)] = pipe.Get(ctx, key)
		}
	}

	_, err = pipe.Exec(ctx)
	if err != nil && !errors.Is(err, redis.Nil) {
		helper.Logger("Exec pipeline", filePath, err)
		return dto.GetBookingStoreResponse{}, errors.New(BASE_MESSAGE)
	}

	lockedMap := make(map[string]bool)

	for compositeKey, cmd := range cmdMap {
		val, err := cmd.Result()
		if err == nil && val != "" {
			lockedMap[compositeKey] = true
		}
	}

	now := time.Now().In(loc)

	var resultSlots []dto.SlotAvailable
	for i, timeStr := range slotStrings {
		slotDateTime := slots[i]
		isPastSlot := slotDateTime.Before(now)

		// FIX: langkah 1 — hitung dulu capster mana saja yang kosong di slot ini,
		// sebelum decide available/tidaknya masing-masing
		var freeCapsterIndexes []int // index c di dataCapsters yang statusnya kosong

		for idx, c := range dataCapsters {
			compositeKey := fmt.Sprintf("%s|%s", timeStr, c.ID.String())
			isBookedDb := dbBookedMap[compositeKey]
			isLockedRedis := lockedMap[compositeKey]

			isFree := !isBookedDb && !isLockedRedis && !isPastSlot
			if isFree {
				freeCapsterIndexes = append(freeCapsterIndexes, idx)
			}
		}

		// FIX: langkah 2 — kalau capster kosong cuma sisa 1, itu direserved (tidak available)
		reservedIdx := -1
		if len(freeCapsterIndexes) == 1 {
			reservedIdx = freeCapsterIndexes[0]
		}

		var capstterResults []dto.CapsterAvailable
		availableCount := 0

		for idx, c := range dataCapsters {
			compositeKey := fmt.Sprintf("%s|%s", timeStr, c.ID.String())
			isBookedDb := dbBookedMap[compositeKey]
			isLockedRedis := lockedMap[compositeKey]

			available := !isBookedDb && !isLockedRedis && !isPastSlot

			// FIX: langkah 3 — kalau capster ini adalah satu-satunya yang tersisa, paksa jadi false
			if idx == reservedIdx {
				available = false
			}

			if available {
				availableCount++
			}

			var avgRating = 5.0
			var totalRating = 0
			for _, r := range c.Ratings {
				totalRating += int(r.Score)
			}

			if len(c.Ratings) > 0 {
				avgRating = float64(totalRating) / float64(len(c.Ratings))
			}

			imageUrl := ""
			if c.ImageUrl != nil {
				imageUrl = *c.ImageUrl
			}

			capstterResults = append(capstterResults, dto.CapsterAvailable{
				Id:        c.ID,
				Name:      c.Name,
				Available: available,
				ImageUrl:  imageUrl,
				AvgRating: avgRating,
			})
		}

		resultSlots = append(resultSlots, dto.SlotAvailable{
			Time:      timeStr,
			Available: !isPastSlot && availableCount > 0, // FIX: >0, karena availableCount sudah otomatis exclude reserved
			Capsters:  capstterResults,
		})
	}

	return dto.GetBookingStoreResponse{
		Date:    req.Date,
		IdStore: idStore,
		Slots:   resultSlots,
	}, nil
}

func (s *bookingService) DeleteLockBooking(ctx context.Context, claims *lib.CustomClaims, reqParams dto.DeleteLockBookingRequest) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat booking"
	_, filePath, _, _ := runtime.Caller(0)

	idUser, err := uuid.Parse(claims.UserId)
	if err != nil {
		return errors.New("Data user tidak valid!")
	}

	idCapster, err := uuid.Parse(reqParams.IdCapster)
	if err != nil {
		return errors.New("Id capster tidak valid!")
	}

	idStore, err := uuid.Parse(reqParams.IdStore)
	if err != nil {
		return errors.New("Id toko tidak valid!")
	}

	userLockKey := fmt.Sprintf("user_lock:%v", idUser)
	_, err = s.client.Get(ctx, userLockKey).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return errors.New("Anda belum melakukan lock booking")
		}

		helper.Logger("find data lock key", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("find one store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	loc, err := time.LoadLocation(string(dataStore.Timezone))
	if err != nil {
		helper.Logger("load timezone", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	scheduledAt := reqParams.BookingDate.In(loc)
	dateSchedule := scheduledAt.Format("2006-01-02")
	timeSchedule := scheduledAt.Format("15:04")

	bookingLockKey := fmt.Sprintf("lock:%v:%v:%v:%v", idStore, dateSchedule, timeSchedule, idCapster)
	_, err = s.client.Get(ctx, bookingLockKey).Result()
	if err != nil {
		if errors.Is(err, redis.Nil) {
			return errors.New("Anda belum melakukan lock booking")
		}

		helper.Logger("find data lock key", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	pipe := s.client.Pipeline()
	pipe.Del(ctx, bookingLockKey)
	pipe.Del(ctx, userLockKey)
	_, err = pipe.Exec(ctx)
	if err != nil {
		helper.Logger("delete lock booking", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *bookingService) GetBookingUser(claims *lib.CustomClaims, reqParams dto.GetBookingUserRequest) ([]dto.GetBookingUserResponse, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data booking!"
	_, filePath, _, _ := runtime.Caller(0)

	var status []entity.BookingStatusEnum

	switch reqParams.StatusBooking {
	case dto.StatusDone:
		status = []entity.BookingStatusEnum{entity.BookingStatusCompleted}
	case dto.StatusUpcoming:
		status = []entity.BookingStatusEnum{
			entity.BookingStatusBooked,
			entity.BookingStatusProgress,
		}
	default:
		status = []entity.BookingStatusEnum{entity.BookingStatusCanceled}
	}

	var scopes []func(*gorm.DB) *gorm.DB
	if reqParams.Query != nil {
		q := "%" + *reqParams.Query + "%"
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where(`
				EXISTS (
					SELECT 1 FROM booking_item bi
					JOIN service s ON s.id = bi.id_service
					WHERE bi.id_booking = booking.id
					AND s.name ILIKE ?
				)
				OR EXISTS (
					SELECT 1 FROM capster c
					WHERE c.id = booking.id_capster
					AND c.name ILIKE ?
				)
				OR EXISTS (
					SELECT 1 FROM store st
					WHERE st.id = booking.id_store
					AND (st.name ILIKE ? OR st.address ILIKE ?)
				)
			`, q, q, q, q)
		})
	}
	var page = 1
	var limit = 20
	var sortBy = dto.SortByBookingDate
	var orderBy = dto.OrderDesc

	if reqParams.Page != nil {
		page = *reqParams.Page
	}

	if reqParams.Limit != nil {
		limit = *reqParams.Limit
	}

	if reqParams.SortBy != nil {
		sortBy = *reqParams.SortBy
	}

	if reqParams.OrderBy != nil {
		orderBy = *reqParams.OrderBy
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Where("status_booking IN ?", status)
	})

	totalData, err := s.bookingRepo.Count(scopes...)
	if err != nil {
		helper.Logger("Count total booking repo", filePath, err)
		return []dto.GetBookingUserResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Clauses(clause.OrderBy{
			Columns: []clause.OrderByColumn{
				{Column: clause.Column{
					Name: string(sortBy),
				},
					Desc: dto.SortBooking(orderBy) == "desc",
				},
			},
		})
	})

	paginationData := helper.GetPaginationData(page, limit, int(totalData))
	bookings, err := s.bookingRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("Find all data booking", filePath, err)
		return []dto.GetBookingUserResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	dataBookings := make([]dto.GetBookingUserResponse, 0, len(bookings))
	for _, b := range bookings {
		dataServices := make([]dto.DataServiceBooking, 0, len(b.BookingItems))
		for _, s := range b.BookingItems {
			dataServices = append(dataServices, dto.DataServiceBooking{
				Id:    s.Service.ID,
				Name:  s.Service.Name,
				Price: s.Service.Price,
			})
		}
		dataBooking := dto.GetBookingUserResponse{
			Id: b.ID,
			Capster: dto.DataCapsterBooking{
				Id:   b.Capster.ID,
				Name: b.Capster.Name,
			},
			Store: dto.DataStoreBooking{
				Id:          b.Store.ID,
				Name:        b.Store.Name,
				Address:     b.Store.Address,
				PhoneNumber: b.Store.PhoneNumber,
			},
			BookingDate: b.ScheduledAt,
			TotalPrice:  b.TotalPrice,
			Service:     dataServices,
			Rating:      nil,
		}

		if b.StatusBooking == entity.BookingStatusCompleted && len(b.Ratings) > 0 {
			var avgRating float64 = 0.0
			totalRating := 0
			ratingCapster := 0
			ratingStaff := 0
			ratingStore := 0
			countRating := 0
			message := ""
			for _, r := range b.Ratings {
				if r.Type == entity.RatingTypeCapster {
					ratingCapster = int(r.Score)
					countRating = 1
				}

				if r.Type == entity.RatingTypeStaff {
					ratingStaff = int(r.Score)
					countRating = 2
				}

				if r.Type == entity.RatingTypeStore {
					ratingStore = int(r.Score)
					countRating = 3
					message = *r.Message
				}

				totalRating += int(r.Score)
			}

			if countRating > 0 {
				avgRating = float64(totalRating) / float64(countRating)
			}

			dataBooking.Rating = &dto.DataRatingBooking{
				AvgRating:     avgRating,
				CapsterRating: ratingCapster,
				StaffRating:   ratingStaff,
				StoreRating:   ratingStore,
				Message:       message,
			}
		}

		dataBookings = append(dataBookings, dataBooking)
	}

	return dataBookings, paginationData, nil
}

func (s *bookingService) AutoCancelBookings(ctx context.Context) error {
	const BASE_MESSAGE = "Terjadi kesalahan di sistem!"
	_, filePath, _, _ := runtime.Caller(0)

	now := time.Now()
	deadline := now.Add(-constant.AUTO_CANCEL_TOLERANCE)

	var scopes []func(*gorm.DB) *gorm.DB
	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.
			Where("status_booking = ?", entity.BookingStatusBooked).
			Where("scheduled_at < ?", deadline)
	})

	dataBookings, err := s.bookingRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("Find all bookings", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if len(dataBookings) == 0 {
		return nil
	}

	var ids []uuid.UUID
	for _, v := range dataBookings {
		ids = append(ids, v.ID)
	}

	err = s.bookingRepo.UpdateStatusMany(ids, entity.BookingStatusCanceled)
	if err != nil {
		helper.Logger("update status many", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
