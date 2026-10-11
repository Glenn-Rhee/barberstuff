package dto

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type CreatePositionReq struct {
	Name         string  `json:"name" binding:"required"`
	BasicSallary float64 `json:"basic_sallary" binding:"required,min=1000"`
}

type GetPositionReq struct {
	Query *string `form:"q" binding:"omitempty"`
}

type GetPositionRes struct {
	ID           uuid.UUID       `json:"id"`
	Name         string          `json:"name"`
	BasicSallary decimal.Decimal `json:"basic_sallary"`
	CreatedAt    time.Time       `json:"created_at"`
}
