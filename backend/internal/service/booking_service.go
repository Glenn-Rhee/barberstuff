package service

import (
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
	"gorm.io/gorm"
)

type BookingService interface {
	LockBooking(req dto.LockBookingRequest, claims *lib.CustomClaims, ctx context.Context) error
}

type bookingService struct {
	bookingRepo repository.BookingRepository
	client      *redis.Client
	capsterRepo repository.CapsterRepository
	storeRepo   repository.StoreRepository
}

func NewBookingService(
	br repository.BookingRepository,
	c *redis.Client,
	cr repository.CapsterRepository,
	sr repository.StoreRepository,
) BookingService {
	return &bookingService{bookingRepo: br, client: c, capsterRepo: cr, storeRepo: sr}
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
	ok, err := s.client.SetNX(ctx, bookingLockKey, userId, 5*time.Minute).Result()
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
