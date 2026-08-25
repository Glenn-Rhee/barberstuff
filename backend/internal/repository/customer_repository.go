package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type CustomerRepository interface {
	Create(tx *gorm.DB, c *entity.Customer) error
	GetByUsername(userName string) (entity.Customer, error)
	FindById(userId string) (entity.Customer, error)
}

type customerRepository struct {
	db *gorm.DB
}

func NewCustomerRepository(db *gorm.DB) CustomerRepository {
	return &customerRepository{db: db}
}

func (r *customerRepository) GetByUsername(username string) (entity.Customer, error) {
	var dataCustomer entity.Customer
	result := r.db.Where("username = ?", username).Select("id", "username").First(&dataCustomer)

	return dataCustomer, result.Error
}

func (r *customerRepository) Create(tx *gorm.DB, c *entity.Customer) error {
	result := tx.Model(&c).Create(c)
	return result.Error
}

func (r *customerRepository) FindById(userId string) (entity.Customer, error) {
	var dataCustomer entity.Customer
	result := r.db.Where("id = ?", userId).Select("id", "username").First(&dataCustomer)
	return dataCustomer, result.Error
}
