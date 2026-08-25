package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type ProductStatusEnum string

const (
	ProductStatusActive   ProductStatusEnum = "active"
	ProductStatusInactive ProductStatusEnum = "inactive"
)

type Service struct {
	ID              uuid.UUID         `gorm:"column:id;primaryKey"`
	Name            string            `gorm:"column:name;not null"`
	Description     *string           `gorm:"column:description"`
	Price           decimal.Decimal   `gorm:"column:price;not null;default:0"`
	DurationMinutes *int              `gorm:"column:duration_minutes"`
	Status          ProductStatusEnum `gorm:"column:status;not null"`
	ImageService    []byte            `gorm:"column:image_service"`
	CreatedAt       time.Time         `gorm:"column:created_at;not null"`
	UpdatedAt       time.Time         `gorm:"column:updated_at;not null"`
}

func (Service) TableName() string {
	return "service"
}
