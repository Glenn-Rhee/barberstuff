package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type PremiumTypeRepository interface {
	FindOne(where string, args ...interface{}) (entity.PremiumType, error)
	FindHighestByPoints(points int) (entity.PremiumType, error)
}

type premiumTypeRepository struct {
	db *gorm.DB
}

func NewPremiumTypeRepository(db *gorm.DB) PremiumTypeRepository {
	return &premiumTypeRepository{db: db}
}

func (r *premiumTypeRepository) FindOne(where string, args ...interface{}) (entity.PremiumType, error) {
	var dataPremium entity.PremiumType
	result := r.db.Where(where, args...).First(&dataPremium)

	return dataPremium, result.Error
}

func (r *premiumTypeRepository) FindHighestByPoints(points int) (entity.PremiumType, error) {
	var data entity.PremiumType
	err := r.db.
		Where("min_points <= ?", points).
		Order("min_points DESC").
		First(&data).Error

	return data, err
}
