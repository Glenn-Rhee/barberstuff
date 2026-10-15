package repository

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type countByStatus struct {
	Status string
	Total  int64
}

type EmployeeAbsentRow struct {
	ID           uuid.UUID
	Name         string
	ImageUrl     *string
	Status       entity.EmployeeStatusEnum
	PositionName string
	IsPresent    bool
}

type EmployeeRepository interface {
	FindOne(query interface{}, args ...interface{}) (entity.Employee, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Employee, error)
	FindAllCapster(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Employee, error)
	Create(tx *gorm.DB, e *entity.Employee) error
	Updates(tx *gorm.DB, v interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	SoftDelete(tx *gorm.DB, id uuid.UUID) (int64, error)
	Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	CountCapster(scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	CountByStatus(scopes ...func(*gorm.DB) *gorm.DB) ([]countByStatus, error)
	FindWithPresence(idStore uuid.UUID, start, end time.Time) ([]EmployeeAbsentRow, error)
	FindOneCapster(query interface{}, args ...interface{}) (entity.Employee, error)
}

type employeeRepository struct {
	db *gorm.DB
}

func NewEmployeeRepository(db *gorm.DB) EmployeeRepository {
	return &employeeRepository{db: db}
}

func (r *employeeRepository) FindOne(query interface{}, args ...interface{}) (entity.Employee, error) {
	var employee entity.Employee
	result := r.db.Where(query, args...).Where("deleted_at IS NULL").First(&employee)
	return employee, result.Error
}

func (r *employeeRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Employee, error) {
	var employees []entity.Employee
	result := r.db.
		Where("employee.deleted_at IS NULL").
		Preload("Position").
		Preload("Store", func(d *gorm.DB) *gorm.DB {
			return d.Select("id", "name")
		}).
		Scopes(scopes...).
		Find(&employees)
	return employees, result.Error
}

func (r *employeeRepository) FindAllCapster(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Employee, error) {
	var employees []entity.Employee
	result := r.db.
		Preload("Ratings", func(d *gorm.DB) *gorm.DB {
			return d.Select("id", "score", "id_capster").
				Where("id_employee IS NOT NULL").
				Where("type = ?", entity.RatingTypeCapster)
		}).
		Scopes(scopes...).
		Joins("JOIN position ON position.id = employee.id_position").
		Where("employee.deleted_at IS NULL").
		Where("position.deleted_at IS NULL").
		Where("position.name ILIKE ?", "%capster%").
		Find(&employees)

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

func (r *employeeRepository) Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	result := r.db.Model(&entity.Employee{}).Scopes(scopes...).Count(&total)
	return total, result.Error
}

func (r *employeeRepository) CountCapster(scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	result := r.db.
		Model(&entity.Employee{}).
		Scopes(scopes...).
		Joins("JOIN position ON position.id = employee.id_position").
		Where("employee.deleted_at IS NULL").
		Where("position.deleted_at IS NULL").
		Where("position.name ILIKE ?", "%capster%").
		Count(&total)
	return total, result.Error
}

func (r *employeeRepository) CountByStatus(scopes ...func(*gorm.DB) *gorm.DB) ([]countByStatus, error) {
	var rows []countByStatus

	err := r.db.Model(&entity.Employee{}).
		Scopes(scopes...).
		Select("status, COUNT(*) AS total").
		Group("status").
		Scan(&rows).Error

	return rows, err
}

func (r *employeeRepository) FindWithPresence(idStore uuid.UUID, start, end time.Time) ([]EmployeeAbsentRow, error) {
	var rows []EmployeeAbsentRow

	err := r.db.Table("employee e").
		Select(`e.id, e.name, e.image_url, e.status,
			p.name AS position_name,
			EXISTS (
				SELECT 1 FROM absent a
				WHERE a.id_employee = e.id
				  AND a.created_at >= ? AND a.created_at < ?
			) AS is_present`, start, end).
		Joins("JOIN position p ON p.id = e.id_position").
		Where("e.deleted_at IS NULL").
		Where("e.id_store = ?", idStore).
		Order("e.name ASC").
		Scan(&rows).Error

	return rows, err
}

func (r *employeeRepository) FindOneCapster(query interface{}, args ...interface{}) (entity.Employee, error) {
	var employee entity.Employee

	result := r.db.
		Joins("JOIN position ON position.id = employee.id_position").
		Where(query, args...).
		Where("employee.deleted_at IS NULL").
		Where("position.deleted_at IS NULL").
		Where("position.name ILIKE ?", "%capster%").
		First(&employee)

	return employee, result.Error
}
