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

type ProductTypeEnum string

const (
	TypeService ProductTypeEnum = "service"
	TypePackage ProductTypeEnum = "package"
)

type Service struct {
	ID          uuid.UUID         `gorm:"column:id;primaryKey"`
	Name        string            `gorm:"column:name;not null"`
	Price       decimal.Decimal   `gorm:"column:price;not null;default:0"`
	Description *string           `gorm:"column:description"`
	Status      ProductStatusEnum `gorm:"column:status;not null"`
	IdStore     uuid.UUID         `gorm:"column:id_store;not null"`
	Type        ProductTypeEnum   `gorm:"column:type;not null"`
	CreatedAt   time.Time         `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time         `gorm:"column:updated_at;not null;autoUpdateTime"`
	DeletedAt   *time.Time        `gorm:"column:deleted_at"`
}

func (Service) TableName() string {
	return "service"
}
