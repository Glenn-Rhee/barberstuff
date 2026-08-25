package repository

import (
	"barberstuff_backend/internal/entity"
	"context"

	"gorm.io/gorm"
)

type CustomerRepository interface {
	Create(ctx context.Context, c *entity.Customer) error
}

type customerRepository struct {
	db *gorm.DB
}

func NewCustomerRepository(db *gorm.DB) CustomerRepository {
	return &customerRepository{db: db}
}

func (r *customerRepository) Create(ctx context.Context, c *entity.Customer) error {
	return nil
}