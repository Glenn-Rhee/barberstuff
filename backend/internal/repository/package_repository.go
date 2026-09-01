package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type PackageRepository interface {
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Package, error)
}

type packageRepository struct {
	db *gorm.DB
}

func NewPackageRepository(db *gorm.DB) PackageRepository {
	return &packageRepository{db: db}
}

func (r *packageRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Package, error) {
	var dataPackage []entity.Package
	result := r.db.Scopes(scopes...).Find(&dataPackage)
	return dataPackage, result.Error
}
