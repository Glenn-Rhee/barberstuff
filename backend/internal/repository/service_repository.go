package repository

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ServiceRepository interface {
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Service, error)
	Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	FindOne(query interface{}, args ...interface{}) (entity.Service, error)
	Create(s *entity.Service) error
	Updates(v interface{}, id uuid.UUID) (int64, error)
	SoftDelete(id uuid.UUID) (int64, error)
}

type serviceRepository struct {
	db *gorm.DB
}

func NewServiceRepository(db *gorm.DB) ServiceRepository {
	return &serviceRepository{db: db}
}

func (r *serviceRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Service, error) {
	var dataService []entity.Service
	result := r.db.Scopes(scopes...).Find(&dataService)
	return dataService, result.Error
}

func (r *serviceRepository) Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	result := r.db.Model(&entity.Service{}).Count(&total).Scopes(scopes...)
	return total, result.Error
}

func (r *serviceRepository) FindOne(query interface{}, args ...interface{}) (entity.Service, error) {
	var data entity.Service
	result := r.db.
		Where(query, args...).
		First(&data)

	return data, result.Error
}

func (r *serviceRepository) Create(s *entity.Service) error {
	result := r.db.Model(&s).Create(s)
	return result.Error
}

func (r *serviceRepository) Updates(v interface{}, id uuid.UUID) (int64, error) {
	result := r.db.
		Model(&entity.Service{}). 
		Where("id = ?", id).
		Where("deleted_at IS NULL").
		Updates(v)

	return result.RowsAffected, result.Error
}

func (r *serviceRepository) SoftDelete(id uuid.UUID) (int64, error) {
	result := r.db.
		Model(&entity.Service{}).
		Where("id = ?", id).
		Update("deleted_at", time.Now())

	return result.RowsAffected, result.Error
}
