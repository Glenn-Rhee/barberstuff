package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type AbsentRepository interface {
	FindOne(query interface{}, args ...interface{}) (entity.Absent, error)
	Create(v *entity.Absent) error
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Absent, error)
}

type absentRepository struct {
	db *gorm.DB
}

func NewAbsentRepository(db *gorm.DB) AbsentRepository {
	return &absentRepository{db: db}
}

func (r *absentRepository) FindOne(query interface{}, args ...interface{}) (entity.Absent, error) {
	var absent entity.Absent
	result := r.db.Where(query, args...).First(&absent)
	return absent, result.Error
}

func (r *absentRepository) Create(v *entity.Absent) error {
	result := r.db.Model(&v).Create(v)
	return result.Error
}

func (r *absentRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Absent, error) {
	var absents []entity.Absent
	result := r.db.
		Preload("Employee", func(d *gorm.DB) *gorm.DB {
			return d.
				Select("id", "name", "image_url", "status", "id_position").
				Preload("Position", func(d *gorm.DB) *gorm.DB {
					return d.Select("id", "name")
				})
		}).
		Scopes(scopes...).
		Find(&absents)

	return absents, result.Error
}
