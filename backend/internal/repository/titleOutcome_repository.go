package repository

import (
	"barberstuff_backend/internal/entity"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type TitleOutcomeRepossitory interface {
	Create(v *entity.TitleOutcome) error
	FindOne(query interface{}, args ...interface{}) (entity.TitleOutcome, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.TitleOutcome, error)
	Updates(v interface{}, id uuid.UUID) (int64, error)
	Delete(id uuid.UUID) (int64, error)
	Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
}

type titleOutcome struct {
	db *gorm.DB
}

func NewTitleOutcomeRepository(d *gorm.DB) TitleOutcomeRepossitory {
	return &titleOutcome{db: d}
}

func (r *titleOutcome) Create(v *entity.TitleOutcome) error {
	return r.db.Model(&v).Create(v).Error
}

func (r *titleOutcome) FindOne(query interface{}, args ...interface{}) (entity.TitleOutcome, error) {
	var titleOutcome entity.TitleOutcome

	result := r.db.Where(query, args...).First(&titleOutcome)

	return titleOutcome, result.Error
}

func (r *titleOutcome) Updates(v interface{}, id uuid.UUID) (int64, error) {
	result := r.db.
		Model(&entity.TitleOutcome{}).
		Where("id = ?", id).
		Updates(v)

	return result.RowsAffected, result.Error
}

func (r *titleOutcome) Delete(id uuid.UUID) (int64, error) {
	result := r.db.
		Where("id = ?", id).
		Delete(&entity.TitleOutcome{})

	return result.RowsAffected, result.Error
}

func (r *titleOutcome) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.TitleOutcome, error) {
	var titles []entity.TitleOutcome

	result := r.db.Model(&entity.TitleOutcome{}).Scopes(scopes...).Find(&titles)
	return titles, result.Error
}

func (r *titleOutcome) Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	result := r.db.Model(&entity.TitleOutcome{}).Scopes(scopes...).Count(&total)
	return total, result.Error
}
