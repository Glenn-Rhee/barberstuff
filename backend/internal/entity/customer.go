package entity

import (
	"time"

	"github.com/google/uuid"
)

type Gender string

const (
	GenderMale   Gender = "Male"
	GenderFemale Gender = "Female"
)

type Customer struct {
	ID             uuid.UUID      `gorm:"column:id;primaryKey"`
	Name           string         `gorm:"column:name;not null"`
	PhoneNumber    *string        `gorm:"column:phone_number"`
	DateOfBirth    *time.Time     `gorm:"column:date_of_birth"`
	Gender         Gender         `gorm:"column:gender"`
	MemberPoints   int            `gorm:"column:member_points;not null;default:100"`
	IdPremiumType  uuid.UUID      `gorm:"column:id_premium_type;not null"`
	ImageCustomer  string         `gorm:"column:image_customer"`
	CreatedAt      time.Time      `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt      time.Time      `gorm:"column:updated_at;not null;autoUpdateTime"`
	PremiumType    *PremiumType   `gorm:"foreignKey:IdPremiumType;references:ID"`
	Authentication Authentication `gorm:"foreignKey:IDCustomer"`
}

func (Customer) TableName() string {
	return "customer"
}
