package entity

import (
	"time"

	"github.com/google/uuid"
)

type Gender string
type PremiumType string

const (
	GenderMale   Gender = "Male"
	GenderFemale Gender = "Female"
)
const (
	PremiumNewbie Gender = "newbie"
	PremiumBestie Gender = "bestie"
	PremiumRoyal  Gender = "royal"
	PremiumCrazy  Gender = "crazy"
)

type Customer struct {
	ID             uuid.UUID      `gorm:"column:id;primaryKey"`
	Name           string         `gorm:"column:name;not null"`
	PhoneNumber    *string        `gorm:"column:phone_number"`
	DateOfBirth    *time.Time     `gorm:"column:date_of_birth"`
	Gender         Gender         `gorm:"column:gender"`
	MemberPoints   int            `gorm:"column:member_points;not null;default:100"`
	PremiumType    PremiumType    `gorm:"column:premium_type;default:newbie"`
	ImageCustomer  string         `gorm:"column:image_customer"`
	CreatedAt      time.Time      `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt      time.Time      `gorm:"column:updated_at;not null;autoUpdateTime"`
	Authentication Authentication `gorm:"foreignKey:IDCustomer"`
}

func (Customer) TableName() string {
	return "customer"
}
