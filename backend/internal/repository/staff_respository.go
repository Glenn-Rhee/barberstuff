package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type StaffRepository interface {
	Create(tx *gorm.DB, s *entity.Staff) error
	FindOne(where string, args ...interface{}) (entity.Staff, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Staff, error)
	FindProfile(userId string) (entity.Staff, error)
}

type staffRepository struct {
	db *gorm.DB
}

func NewStaffRepository(db *gorm.DB) StaffRepository {
	return &staffRepository{db: db}
}

func (r *staffRepository) Create(tx *gorm.DB, s *entity.Staff) error {
	result := tx.Model(&entity.Staff{}).Where("deleted_at IS NULL").Create(s)

	return result.Error
}

func (r *staffRepository) FindOne(where string, args ...interface{}) (entity.Staff, error) {
	var dataStaff entity.Staff
	result := r.db.Where(where, args...).First(&dataStaff)

	return dataStaff, result.Error
}

func (r *staffRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Staff, error) {
	var dataStaffes []entity.Staff
	result := r.db.
		Select("staff.id", "staff.name", "staff.id_store", "staff.created_at").
		Preload("Authentication", func(db *gorm.DB) *gorm.DB {
			return db.Select("id", "id_staff", "role", "email")
		}).
		Where("staff.deleted_at IS NULL").
		Scopes(scopes...).
		Find(&dataStaffes)
	return dataStaffes, result.Error
}

func (r *staffRepository) FindProfile(userId string) (entity.Staff, error) {
	var dataStaff entity.Staff

	result := r.db.
		Select("staff.id", "staff.name", "staff.id_store", "staff.created_at").
		Preload("Authentication", func(db *gorm.DB) *gorm.DB {
			return db.Select("id", "id_staff", "role", "email")
		}).
		Where("staff.id = ?", userId).
		Where("staff.deleted_at IS NULL").
		First(&dataStaff)

	return dataStaff, result.Error
}
