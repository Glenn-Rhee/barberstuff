package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type PromoRepository interface {
	FindOne(query interface{}, args ...interface{}) (entity.PromoClaimed, error)
}

type promoRepository struct {
	db *gorm.DB
}

func NewPromoRepository(db *gorm.DB) PromoRepository {
	return &promoRepository{db: db}
}

func (r *promoRepository) FindOne(query interface{}, args ...interface{}) (entity.PromoClaimed, error) {
	var data entity.PromoClaimed

	result := r.db.
		Preload("Promo").
		Where(query, args...).
		First(&data)

	return data, result.Error
}
