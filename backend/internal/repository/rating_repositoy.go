package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type RatingRepository interface {
	FindAll(where interface{}, args ...interface{}) ([]entity.Rating, error)
}

type ratingRepository struct {
	db *gorm.DB
}

func NewRatingRepository(db *gorm.DB) RatingRepository {
	return &ratingRepository{db: db}
}

func (r *ratingRepository) FindAll(where interface{}, args ...interface{}) ([]entity.Rating, error) {
	var dataRating []entity.Rating
	result := r.db.
		Select("id", "id_user", "id_store", "score", "message", "created_at").
		Preload("Customer", func(db *gorm.DB) *gorm.DB {
			return db.Select("id", "name", "image_customer", "id_premium_type").
				Preload("PremiumType")
		}).
		Where(where, args...).
		Find(&dataRating)
	return dataRating, result.Error
}
