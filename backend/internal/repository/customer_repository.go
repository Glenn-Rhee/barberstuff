package repository

import (
	"barberstuff_backend/internal/entity"
	"context"
	"database/sql"
)

type CustomerRepository interface {
	Create(ctx context.Context, c *entity.Customer) error
}

type customerRepository struct {
	db *sql.DB
}

func NewCustomerRepository(db *sql.DB) CustomerRepository {
	return &customerRepository{db: db}
}

func (r *customerRepository) Create(ctx context.Context, c *entity.Customer) error {
	return nil
}