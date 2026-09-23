package repository

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type StaffRepository interface {
	Create(tx *gorm.DB, s *entity.Staff) error
	FindOne(where string, args ...interface{}) (entity.Staff, error)
	FindOneUnscoped(where string, args ...interface{}) (entity.Staff, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Staff, error)
	FindProfile(userId string) (entity.Staff, error)
	Updates(value interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	SoftDelete(id uuid.UUID) error
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
	result := r.db.Preload("Authentication").Where(where, args...).Where("deleted_at IS NULL").First(&dataStaff)

	return dataStaff, result.Error
}

func (r *staffRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Staff, error) {
	var dataStaffes []entity.Staff
	result := r.db.
		Select("staff.id", "staff.name", "staff.id_store", "staff.created_at").
		Preload("Authentication", func(db *gorm.DB) *gorm.DB {
			return db.Select("id", "id_staff", "role", "email")
		}).
		Preload("Ratings", func(db *gorm.DB) *gorm.DB {
			return db.Select("id", "score", "id_staff").
				Where("id_staff IS NOT NULL").
				Where("type = ?", entity.RatingTypeStaff)
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

func (r *staffRepository) Updates(value interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	result := r.db.
		Model(&entity.Staff{}).
		Scopes(scopes...).
		Updates(value)
	return result.RowsAffected, result.Error
}

func (r *staffRepository) SoftDelete(id uuid.UUID) error {
	result := r.db.
		Model(&entity.Staff{}).
		Where("id = ?", id).
		Update("deleted_at", time.Now())
	return result.Error
}

func (r *staffRepository) FindOneUnscoped(where string, args ...interface{}) (entity.Staff, error) {
	var dataStaff entity.Staff
	result := r.db.Preload("Authentication").Where(where, args...).First(&dataStaff)
	return dataStaff, result.Error
}
