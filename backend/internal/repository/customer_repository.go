package repository

import (
	"barberstuff_backend/internal/entity"
	"time"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type CustomerRepository interface {
	Create(tx *gorm.DB, c *entity.Customer) error
	FindById(userId string) (entity.Customer, error)
	FindProfile(userId string) (entity.Customer, error)
	FindOne(where interface{}, args ...interface{}) (entity.Customer, error)
	Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Customer, error)
	CountNewCustomers(startDate, endDate time.Time) (int64, error)
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

func (r *customerRepository) FindOne(where interface{}, args ...interface{}) (entity.Customer, error) {
	var dataCustomer entity.Customer
	result := r.db.Where(where, args...).First(&dataCustomer)
	return dataCustomer, result.Error
}

func (r *customerRepository) Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	result := r.db.Model(&entity.Customer{}).Count(&total).Scopes(scopes...)
	return total, result.Error
}

func (r *customerRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Customer, error) {
	var dataCustomer []entity.Customer
	result := r.db.
		Preload("Authentication", func(db *gorm.DB) *gorm.DB {
			return db.Select("id", "id_customer", "email")
		}).
		Preload("PremiumType").
		Preload("Bookings", func(db *gorm.DB) *gorm.DB {
			return db.
				Preload("Capster").
				Preload("BookingItems", func(db *gorm.DB) *gorm.DB {
					return db.Preload("Service")
				}).
				Clauses(clause.OrderBy{
					Columns: []clause.OrderByColumn{
						{
							Column: clause.Column{Name: "scheduled_at"},
							Desc:   true,
						},
					},
				})
		}).
		Preload("PremiumType").
		Scopes(scopes...).
		Find(&dataCustomer)

	return dataCustomer, result.Error
}

func (r *customerRepository) CountNewCustomers(startDate, endDate time.Time) (int64, error) {
	var count int64
	err := r.db.Model(&entity.Customer{}).
		Where("created_at >= ? AND created_at < ?", startDate, endDate).
		Count(&count).Error
	return count, err
}
