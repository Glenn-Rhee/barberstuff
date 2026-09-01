package repository

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type StoreRepository interface {
	Create(s *entity.Store) error
	FindOne(where string, args ...interface{}) (entity.Store, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Store, error)
	Update(s *entity.Store) error
	SoftDelete(storeId uuid.UUID) error
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
	result := r.db.Where(where, args...).Where("deleted_at IS NULL").First(&dataStore)
	return dataStore, result.Error
}

func (r *storeRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Store, error) {
	var stores []entity.Store
	result := r.db.Scopes(scopes...).Find(&stores)
	return stores, result.Error
}

func (r *storeRepository) Update(s *entity.Store) error {
	result := r.db.Save(s)
	return result.Error
}

func (r *storeRepository) SoftDelete(storeId uuid.UUID) error {
	result := r.db.Model(&entity.Store{}).Where("id = ?", storeId).Update("deleted_at", time.Now())
	return result.Error
}