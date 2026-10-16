package repository

import (
	"barberstuff_backend/internal/entity"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type BenefitRepository interface {
	Create(tx *gorm.DB, b *entity.Benefit) error
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Benefit, error)
	Updates(v interface{}, id uuid.UUID) (int64, error)
	FindOne(where interface{}, args ...interface{}) (entity.Benefit, error)
	Delete(id uuid.UUID) (int64, error)
}

type benefitRepository struct {
	db *gorm.DB
}

func NewBenefitRepository(db *gorm.DB) BenefitRepository {
	return &benefitRepository{db: db}
}

func (r *benefitRepository) Create(tx *gorm.DB, b *entity.Benefit) error {
	return tx.Model(&b).Create(b).Error
}

func (r *benefitRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Benefit, error) {
	var benefits []entity.Benefit

	result := r.db.Model(&entity.Benefit{}).Scopes(scopes...).Find(&benefits)

	return benefits, result.Error
}

func (r *benefitRepository) Updates(v interface{}, id uuid.UUID) (int64, error) {
	result := r.db.
		Model(&entity.Benefit{}).
		Where("id = ?", id).
		Updates(v)

	return result.RowsAffected, result.Error
}

func (r *benefitRepository) FindOne(where interface{}, args ...interface{}) (entity.Benefit, error) {
	var benefit entity.Benefit
	result := r.db.Where(where, args...).First(&benefit)

	return benefit, result.Error
}

func (r *benefitRepository) Delete(id uuid.UUID) (int64, error) {
	result := r.db.Where("id = ?").Delete(&entity.Benefit{})

	return result.RowsAffected, result.Error
}
