package repository

import (
	"barberstuff_backend/internal/entity"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type StaffRepository interface {
	Create(tx *gorm.DB, s *entity.Staff) error
	FindOne(where string, args ...interface{}) (entity.Staff, error)
	CountByStoreAndRole(idStore uuid.UUID, role entity.RoleEnum) (int64, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Staff, error)
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

func (r *staffRepository) CountByStoreAndRole(idStore uuid.UUID, role entity.RoleEnum) (int64, error) {
	var count int64
	err := r.db.Table("staff").
		Joins("JOIN authentication ON authentication.id_staff = staff.id").
		Where("staff.id_store = ?", idStore).
		Where("authentication.role = ?", role).
		Where("staff.deleted_at IS NULL").
		Count(&count).Error
	return count, err
}

func (r *staffRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Staff, error) {
	var dataStaffes []entity.Staff
	result := r.db.
		Select("id").
		Preload("Authentication", func(db *gorm.DB) *gorm.DB  {
			return db.Select("id", "id_staff", "role", "email")
		}).
		Scopes(scopes...).
		Find(&dataStaffes)
	return dataStaffes, result.Error
}
