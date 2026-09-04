package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type CapsterRepository interface {
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Capster, error)
}

type capsterRepository struct {
	db *gorm.DB
}

func NewCapsterRepository(db *gorm.DB) CapsterRepository {
	return &capsterRepository{db: db}
}

func (r *capsterRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Capster, error) {
	var dataCapster []entity.Capster
	result := r.db.
		Preload("Ratings", func(db *gorm.DB) *gorm.DB {
			return db.Select("id", "score")
		}).
		Scopes(scopes...).
		Find(&dataCapster)
	return dataCapster, result.Error
}
