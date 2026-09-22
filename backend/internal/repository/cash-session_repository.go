package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type CashSessionRepository interface {
	Create(c *entity.CashSession) error
	FindOne(query interface{}, args ...interface{}) (entity.CashSession, error)
}

type cashSessionRepository struct {
	db *gorm.DB
}

func NewCashSessionRepository(db *gorm.DB) CashSessionRepository {
	return &cashSessionRepository{db: db}
}

func (r *cashSessionRepository) Create(c *entity.CashSession) error {
	result := r.db.Model(&c).Create(c)
	return result.Error
}

func (r *cashSessionRepository) FindOne(query interface{}, args ...interface{}) (entity.CashSession, error) {
	var data entity.CashSession
	result := r.db.
		Preload("Transactions").
		Where(query, args...).
		First(&data)

	return data, result.Error
}
