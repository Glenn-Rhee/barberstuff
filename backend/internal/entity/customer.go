package entity

import (
	"time"

	"github.com/google/uuid"
)

type Customer struct {
	ID           uuid.UUID  `gorm:"column:id;primaryKey"`
	Name         string     `gorm:"column:name;not null"`
	PhoneNumber  *string    `gorm:"column:phone_number"`
	DateOfBirth  *time.Time `gorm:"column:date_of_birth"`
	Gender       *string    `gorm:"column:gender"`
	Username     string     `gorm:"column:username;not null;unique"`
	MemberPoints int        `gorm:"column:member_points;not null;default:0"`
	CreatedAt    time.Time  `gorm:"column:created_at;not null"`
	UpdatedAt    time.Time  `gorm:"column:updated_at;not null"`
}

func (Customer) TableName() string {
	return "customer"
}
