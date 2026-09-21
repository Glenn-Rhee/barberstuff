package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type BookingItemRepository interface {
	Create(tx *gorm.DB, b *entity.BookingItem) error
	Delete(query interface{}, args ...interface{}) (int64, error)
}

type bookingItemRepository struct {
	db *gorm.DB
}

func NewBookingItemRepository(db *gorm.DB) BookingItemRepository {
	return &bookingItemRepository{db: db}
}

func (r *bookingItemRepository) Create(tx *gorm.DB, b *entity.BookingItem) error {
	return tx.Create(&b).Error
}

func (r *bookingItemRepository) Delete(query interface{}, args ...interface{}) (int64, error) {
	result := r.db.Where(query, args...).Delete(&entity.BookingItem{})

	return result.RowsAffected, result.Error
}
