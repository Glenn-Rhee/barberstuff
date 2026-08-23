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
	ID              uuid.UUID         `db:"id"`
	Name            string            `db:"name"`
	Description     *string           `db:"description"`
	Price           decimal.Decimal   `db:"price"`
	DurationMinutes *int              `db:"duration_minutes"`
	Status          ProductStatusEnum `db:"status"`
	ImageService    []byte            `db:"image_service"`
	CreatedAt       time.Time         `db:"created_at"`
	UpdatedAt       time.Time         `db:"updated_at"`
}