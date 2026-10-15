package dto

import (
	"barberstuff_backend/internal/entity"
	"time"
)

type CreatePromoReq struct {
	Title              string                  `json:"title" binding:"required,min=1,max=50"`
	Status             entity.PromoStatusEnum  `json:"status" binding:"required,oneof=visible hide"`
	Description        *string                 `json:"description" binding:"omitempty"`
	DiscountType       entity.DiscountTypeEnum `json:"discount_type" binding:"required,oneof=percentage fixed"`
	DiscountValue      float64                 `json:"discount_value" binding:"required,numeric,min=1"`
	UsageLimitCustomer *int64                  `json:"usage_limit_customer" binding:"omitempty,min=1"`
	StartAt            time.Time               `json:"start_at" binding:"required"`
	ExpiredAt          time.Time               `json:"expired_at" binding:"required"`
	ImageUrl           string                  `json:"image_url" binding:"required"`
}
