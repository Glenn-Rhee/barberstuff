package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type BookingRepository interface {
	FindOne(query interface{}, args ...interface{}) (entity.Booking, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Booking, error)
	Create(tx *gorm.DB, b *entity.Booking) error
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
		Preload("BookingItems").
		Scopes(scopes...).
		Find(&dataBooking)

	return dataBooking, result.Error
}

func (r *bookingRepository) Create(tx *gorm.DB, b *entity.Booking) error {
	return tx.Create(&b).Error
}
