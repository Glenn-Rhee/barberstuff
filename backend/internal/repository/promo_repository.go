package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type PromoRepository interface {
	FindOne(query interface{}, args ...interface{}) (entity.PromoClaimed, error)
	Create(v *entity.Promo) error
	Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Promo, error)
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

func (r *promoRepository) Create(v *entity.Promo) error {
	return r.db.Model(&v).Create(v).Error
}

func (r *promoRepository) Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	result := r.db.
		Model(&entity.Promo{}).
		Scopes(scopes...).
		Count(&total)

	return total, result.Error
}

func (r *promoRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Promo, error) {
	var promoes []entity.Promo
	result := r.db.Model(&entity.Promo{}).Scopes(scopes...).Find(&promoes)
	return promoes, result.Error
}
