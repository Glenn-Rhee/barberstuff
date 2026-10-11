package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type EmployeeStatusEnum string

const (
	EmployeeStatusActive   EmployeeStatusEnum = "active"
	EmployeeStatusInactive EmployeeStatusEnum = "inactive"
)

type EmployeeGenderEnum string

const (
	EmployeeGenderMale   EmployeeGenderEnum = "male"
	EmployeeGenderFemale EmployeeGenderEnum = "female"
)

type Employee struct {
	ID                  uuid.UUID           `gorm:"column:id;primaryKey;default:gen_random_uuid()"`
	IdPosition          uuid.UUID           `gorm:"column:id_position;not null"`
	IdStore             *uuid.UUID          `gorm:"column:id_store"`
	Name                string              `gorm:"column:name;not null"`
	PhoneNumber         *string             `gorm:"column:phone_number"`
	BasicSalary         *decimal.Decimal    `gorm:"column:basic_salary"`
	Email               *string             `gorm:"column:email"`
	Gender              *EmployeeGenderEnum `gorm:"column:gender"`
	DateOfBirth         *time.Time          `gorm:"column:date_of_birth;type:date"`
	Address             *string             `gorm:"column:address"`
	Status              EmployeeStatusEnum  `gorm:"column:status;not null;default:active"`
	NationalIDNumber    *string             `gorm:"column:national_id_number"`
	ImageUrl            *string             `gorm:"column:image_url"`
	IdentityDocumentUrl *string             `gorm:"column:identity_document_url"`
	CreatedAt           time.Time           `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt           time.Time           `gorm:"column:updated_at;not null;autoUpdateTime"`
	DeletedAt           *time.Time          `gorm:"column:deleted_at"`

	Position Position `gorm:"foreignKey:IdPosition"`
	Store    *Store   `gorm:"foreignKey:IdStore"`
}

func (Employee) TableName() string {
	return "employee"
}
