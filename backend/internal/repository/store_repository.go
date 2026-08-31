package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type StoreRepository interface {
	Create(s *entity.Store) error
	FindOne(where string, args ...interface{}) (entity.Store, error)
}

type storeRepository struct {
	db *gorm.DB
}

func NewStoreRepository(db *gorm.DB) StoreRepository {
	return &storeRepository{db: db}
}

func (r *storeRepository) Create(s *entity.Store) error {
	result := r.db.Model(&s).Create(s)
	return result.Error
}

func (r *storeRepository) FindOne(where string, args ...interface{}) (entity.Store, error) {
	var dataStore entity.Store
	result := r.db.Where(where, args...).First(&dataStore)
	return dataStore, result.Error
}
