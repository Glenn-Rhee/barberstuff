package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type CustomerRepository interface {
	Create(tx *gorm.DB, c *entity.Customer) error
	FindById(userId string) (entity.Customer, error)
	FindProfile(userId string) (entity.Customer, error)
}

type customerRepository struct {
	db *gorm.DB
}

func NewCustomerRepository(db *gorm.DB) CustomerRepository {
	return &customerRepository{db: db}
}

func (r *customerRepository) Create(tx *gorm.DB, c *entity.Customer) error {
	result := tx.Model(&c).Create(c)
	return result.Error
}

func (r *customerRepository) FindById(userId string) (entity.Customer, error) {
	var dataCustomer entity.Customer
	result := r.db.Where("id = ?", userId).First(&dataCustomer)
	return dataCustomer, result.Error
}

func (r *customerRepository) FindProfile(userId string) (entity.Customer, error) {
	var dataCustomers entity.Customer

	result := r.db.
		Preload("Authentication", func(db *gorm.DB) *gorm.DB {
			return db.Select("id", "id_customer", "role", "email", "is_verified", "login_type", "oauth_provider")
		}).
		Where("customer.id = ?", userId).
		First(&dataCustomers)

	return dataCustomers, result.Error
}
