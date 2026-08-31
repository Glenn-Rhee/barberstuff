package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type StaffRepository interface {
	Create(tx *gorm.DB, s *entity.Staff) error
	FindOne(where string, args ...interface{}) (entity.Staff, error)
}

type staffRepository struct {
	db *gorm.DB
}

func NewStaffRepository(db *gorm.DB) StaffRepository {
	return &staffRepository{db: db}
}

func (r *staffRepository) Create(tx *gorm.DB, s *entity.Staff) error {
	result := tx.Model(&entity.Staff{}).Create(s)

	return result.Error
}

func (r *staffRepository) FindOne(where string, args ...interface{}) (entity.Staff, error) {
	var dataStaff entity.Staff
	result := r.db.Where(where, args...).First(&dataStaff)

	return dataStaff, result.Error
}
