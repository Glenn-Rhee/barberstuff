package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type TransactionsRepository interface {
	Create(tx *gorm.DB, t *entity.Transactions) error
	FindOne(where string, args ...interface{}) (entity.Transactions, error)
	Updates(tx *gorm.DB, value interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
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

func (r *transactionsRepository) FindOne(where string, args ...interface{}) (entity.Transactions, error) {
	var dataTransaction entity.Transactions

	result := r.db.
		Where(where, args...).
		Where("deleted_at IS NULL").
		First(&dataTransaction)

	return dataTransaction, result.Error
}

func (r *transactionsRepository) Updates(tx *gorm.DB, value interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	result := tx.
		Model(&entity.Transactions{}).
		Scopes(scopes...).
		Updates(value)

	return result.RowsAffected, result.Error
}
