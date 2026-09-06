package dto

import (
	"barberstuff_backend/internal/entity"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type ServiceData struct {
	Id              uuid.UUID                `json:"id"`
	Name            string                   `json:"string"`
	Price           decimal.Decimal          `json:"price"`
	DurationMinutes *int                     `json:"duration_minutes"`
	Description     *string                  `json:"description"`
	Status          entity.ProductStatusEnum `json:"status"`
}
