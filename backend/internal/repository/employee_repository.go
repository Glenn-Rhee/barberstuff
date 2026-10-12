package repository

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type EmployeeRepository interface {
	FindOne(query interface{}, args ...interface{}) (entity.Employee, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Employee, error)
	Create(tx *gorm.DB, e *entity.Employee) error
	Updates(tx *gorm.DB, v interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	SoftDelete(tx *gorm.DB, id uuid.UUID) (int64, error)
}

type employeeRepository struct {
	db *gorm.DB
}

func NewEmployeeRepository(db *gorm.DB) EmployeeRepository {
	return &employeeRepository{db: db}
}

func (r *employeeRepository) FindOne(query interface{}, args ...interface{}) (entity.Employee, error) {
	var employee entity.Employee
	result := r.db.Where(query, args...).First(&employee)
	return employee, result.Error
}

func (r *employeeRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Employee, error) {
	var employees []entity.Employee
	result := r.db.Scopes(scopes...).Find(&employees)
	return employees, result.Error
}

func (r *employeeRepository) Create(tx *gorm.DB, e *entity.Employee) error {
	return tx.Model(&e).Create(e).Error
}

func (r *employeeRepository) Updates(tx *gorm.DB, v interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	result := tx.Model(&entity.Employee{}).
		Scopes(scopes...).
		Where("deleted_at IS NULL").
		Updates(v)

	return result.RowsAffected, result.Error
}

func (r *employeeRepository) SoftDelete(tx *gorm.DB, id uuid.UUID) (int64, error) {
	result := tx.Model(&entity.Employee{}).
		Where("id = ?", id).
		Where("deleted_at IS NULL").
		Update("deleted_at", time.Now())

	return result.RowsAffected, result.Error
}
