package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type AbsentRepository interface {
	FindOne(query interface{}, args ...interface{}) (entity.Absent, error)
	Create(v *entity.Absent) error
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