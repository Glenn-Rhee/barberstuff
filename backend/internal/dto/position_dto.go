package dto

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type CreatePositionReq struct {
	Name        string  `json:"name" binding:"required"`
	BasicSalary float64 `json:"basic_salary" binding:"required,min=1000"`
}

type GetPositionReq struct {
	Query *string `form:"q" binding:"omitempty"`
}

type GetPositionRes struct {
	ID          uuid.UUID       `json:"id"`
	Name        string          `json:"name"`
	BasicSalary decimal.Decimal `json:"basic_salary"`
	CreatedAt   time.Time       `json:"created_at"`
}

type UpdatePositionReq struct {
	Name        *string  `json:"name" binding:"omitempty"`
	BasicSalary *float64 `json:"basic_salary" binding:"omitempty,min=1000"`
}
