package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type CapsterRepository interface {
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Capster, error)
	FindOne(query interface{}, args ...interface{}) (entity.Capster, error)
	Create(c *entity.Capster) error
	Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
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
			return db.Select("id", "score", "id_staff")
		}).
		Scopes(scopes...).
		Find(&dataCapster)
	return dataCapster, result.Error
}

func (r *capsterRepository) FindOne(query interface{}, args ...interface{}) (entity.Capster, error) {
	var dataCapster entity.Capster
	result := r.db.
		Where(query, args...).
		Where("deleted_at IS NULL").
		First(&dataCapster)

	return dataCapster, result.Error
}

func (r *capsterRepository) Create(c *entity.Capster) error {
	result := r.db.Model(&c).Create(c)
	return result.Error
}

func (r *capsterRepository) Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	result := r.db.Model(&entity.Capster{}).Count(&total).Scopes(scopes...)
	return total, result.Error
}
