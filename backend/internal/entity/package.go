package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type Package struct {
	ID              uuid.UUID         `db:"id"`
	Name            string            `db:"name"`
	Description     *string           `db:"description"`
	Price           decimal.Decimal   `db:"price"`
	DurationMinutes *int              `db:"duration_minutes"`
	Status          ProductStatusEnum `db:"status"`
	ImagePackage    []byte            `db:"image_package"`
	CreatedAt       time.Time         `db:"created_at"`
	UpdatedAt       time.Time         `db:"updated_at"`
}

type PackageService struct {
	ID        uuid.UUID `db:"id"`
	IDService uuid.UUID `db:"id_service"`
	IDPackage uuid.UUID `db:"id_package"`
	CreatedAt time.Time `db:"created_at"`
}