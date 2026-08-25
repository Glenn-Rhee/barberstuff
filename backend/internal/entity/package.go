package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type Package struct {
	ID              uuid.UUID         `gorm:"column:id;primaryKey"`
	Name            string            `gorm:"column:name;not null"`
	Description     *string           `gorm:"column:description"`
	Price           decimal.Decimal   `gorm:"column:price;not null;default:0"`
	DurationMinutes *int              `gorm:"column:duration_minutes"`
	Status          ProductStatusEnum `gorm:"column:status;not null"` // reuse enum dari service.go
	ImagePackage    []byte            `gorm:"column:image_package"`
	CreatedAt       time.Time         `gorm:"column:created_at;not null"`
	UpdatedAt       time.Time         `gorm:"column:updated_at;not null"`
}

func (Package) TableName() string {
	return "package"
}

type PackageService struct {
	ID        uuid.UUID `gorm:"column:id;primaryKey"`
	IDService uuid.UUID `gorm:"column:id_service;not null"`
	IDPackage uuid.UUID `gorm:"column:id_package;not null"`
	CreatedAt time.Time `gorm:"column:created_at;not null"`
}

func (PackageService) TableName() string {
	return "package_service"
}
