package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type BookingItemRepository interface {
	Create(tx *gorm.DB, b *entity.BookingItem) error
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
