package repository

import (
	"barberstuff_backend/internal/entity"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type BookingRepository interface {
	FindOne(query interface{}, args ...interface{}) (entity.Booking, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Booking, error)
	Create(tx *gorm.DB, b *entity.Booking) error
	Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	UpdateStatusMany(ids []uuid.UUID, status entity.BookingStatusEnum) error
}

type bookingRepository struct {
	db *gorm.DB
}

func NewBookingRepository(db *gorm.DB) BookingRepository {
	return &bookingRepository{db: db}
}

func (r *bookingRepository) FindOne(query interface{}, args ...interface{}) (entity.Booking, error) {
	var data entity.Booking
	result := r.db.
		Preload("BookingItems").
		Where(query, args...).First(&data)
	return data, result.Error
}

func (r *bookingRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Booking, error) {
	var dataBooking []entity.Booking
	result := r.db.
		Preload("Store").
		Preload("Capster").
		Preload("Staff").
		Preload("Ratings", func(db *gorm.DB) *gorm.DB {
			return db.Preload("Store").
				Preload("Capster").
				Preload("Staff")
		}).
		Preload("BookingItems", func(db *gorm.DB) *gorm.DB {
			return db.Preload("Service")
		}).
		Scopes(scopes...).
		Find(&dataBooking)

	return dataBooking, result.Error
}

func (r *bookingRepository) Create(tx *gorm.DB, b *entity.Booking) error {
	return tx.Create(&b).Error
}

func (r *bookingRepository) Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	result := r.db.Model(&entity.Booking{}).Count(&total).Scopes(scopes...)
	return total, result.Error
}

func (r *bookingRepository) UpdateStatusMany(ids []uuid.UUID, status entity.BookingStatusEnum) error {
	return r.db.Model(&entity.Booking{}).
		Where("id IN ?", ids).
		Update("status_booking", status).Error
}
