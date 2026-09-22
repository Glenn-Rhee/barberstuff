package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type TransactionsRepository interface {
	Create(tx *gorm.DB, t *entity.Transactions) error
}

type transactionsRepository struct {
	db *gorm.DB
}

func NewTransactionsRepository(db *gorm.DB) TransactionsRepository {
	return &transactionsRepository{db: db}
}

func (r *transactionsRepository) Create(tx *gorm.DB, t *entity.Transactions) error {
	result := tx.Model(&t).Create(t)
	return result.Error
}
