package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type ServiceRepository interface {
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Service, error)
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
