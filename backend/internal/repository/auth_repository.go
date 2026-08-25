package repository

import (
	"barberstuff_backend/internal/entity"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type AuthenticationRepository interface {
	GetByEmail(email string) (entity.Authentication, error)
	Create(tx *gorm.DB, a *entity.Authentication) error
	UpdateVerifiedCredential(tx *gorm.DB, userId uuid.UUID, verified bool) error
}

type authenticationRepository struct {
	db *gorm.DB
}

func NewAuthRepository(db *gorm.DB) AuthenticationRepository {
	return &authenticationRepository{db: db}
}

func (r *authenticationRepository) GetByEmail(email string) (entity.Authentication, error) {
	var dataAuth entity.Authentication
	result := r.db.Where("email = ?", email).First(&dataAuth)

	return dataAuth, result.Error
}

func (r *authenticationRepository) Create(tx *gorm.DB, a *entity.Authentication) error {
	result := tx.Model(&a).Create(a)
	return result.Error
}

func (r *authenticationRepository) UpdateVerifiedCredential(tx *gorm.DB, userId uuid.UUID, verified bool) error {
	result := tx.Model(&entity.Authentication{}).Where("id_customer = ?",userId).Update("is_verified", verified)
	return result.Error
}
