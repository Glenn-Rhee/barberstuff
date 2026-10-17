package repository

import (
	"barberstuff_backend/internal/entity"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type RatingRepository interface {
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Rating, error)
	Create(tx *gorm.DB, d *entity.Rating) error
	FindOne(where interface{}, args ...interface{}) (entity.Rating, error)
	Updates(value interface{}, id uuid.UUID) error
	Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
}

type ratingRepository struct {
	db *gorm.DB
}

func NewRatingRepository(db *gorm.DB) RatingRepository {
	return &ratingRepository{db: db}
}

func (r *ratingRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Rating, error) {
	var dataRating []entity.Rating
	result := r.db.
		Select("id", "id_user", "id_store", "score", "message", "created_at").
		Preload("Customer", func(db *gorm.DB) *gorm.DB {
			return db.Select("id", "name", "image_customer", "id_premium_type").
				Preload("PremiumType")
		}).
		Scopes(scopes...).
		Find(&dataRating)
	return dataRating, result.Error
}

func (r *ratingRepository) Create(tx *gorm.DB, d *entity.Rating) error {
	return tx.Create(&d).Error
}

func (r *ratingRepository) FindOne(where interface{}, args ...interface{}) (entity.Rating, error) {
	var dataRating entity.Rating
	result := r.db.Where(where, args...).First(&dataRating)
	return dataRating, result.Error
}

func (r *ratingRepository) Updates(value interface{}, id uuid.UUID) error {
	return r.db.
		Model(&entity.Rating{}).
		Where("id = ?", id).
		Updates(value).Error
}

func (r *ratingRepository) Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	result := r.db.Model(&entity.Rating{}).Scopes(scopes...).Count(&total)
	return total, result.Error
}
