package dto

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type CreatePromoReq struct {
	Title              string                  `json:"title" binding:"required,min=1,max=50"`
	Status             entity.PromoStatusEnum  `json:"status" binding:"required,oneof=visible hide"`
	Description        *string                 `json:"description" binding:"omitempty"`
	DiscountType       entity.DiscountTypeEnum `json:"discount_type" binding:"required,oneof=percentage fixed"`
	DiscountValue      float64                 `json:"discount_value" binding:"required,numeric,min=1"`
	UsageLimitCustomer *int64                  `json:"usage_limit_customer" binding:"omitempty,numeric,min=1"`
	MinMemberPoints    *int64                  `json:"min_member_points" binding:"omitempty,numeric,min=1"`
	StartAt            *time.Time              `json:"start_at" binding:"omitempty"`
	ExpiredAt          *time.Time              `json:"expired_at" binding:"omitempty"`
	ImageUrl           string                  `json:"image_url" binding:"omitempty"`
}

type SortPromo string

const (
	SortPromoByName      SortPromo = "name"
	SortPromoByCreatedAt SortPromo = "created_at"
	SortPromoByValue     SortPromo = "discount_value"
)

type GetPromoReq struct {
	Query        *string                  `form:"q" binding:"omitempty"`
	Status       *entity.PromoStatusEnum  `form:"status" binding:"omitempty,oneof=visible hide"`
	DiscountType *entity.DiscountTypeEnum `form:"discount_type" binding:"omitempty,oneof=percentage fixed"`
	SortBy       *SortPromo               `form:"sort_by" binding:"omitempty"`
	RequestParamsPagination
}

type GetPromoRes struct {
	ID                 uuid.UUID               `json:"id"`
	Title              string                  `json:"title"`
	Status             entity.PromoStatusEnum  `json:"status"`
	Description        *string                 `json:"description"`
	DiscountType       entity.DiscountTypeEnum `json:"discount_type"`
	DiscountValue      decimal.Decimal         `json:"discount_value"`
	UsageLimitCustomer *int64                  `json:"usage_limit_customer"`
	MinMemberPoints    *int64                  `json:"min_member_points"`
	StartAt            *time.Time              `json:"start_at"`
	ExpiredAt          *time.Time              `json:"expired_at"`
	ImageUrl           string                  `json:"image_url"`
}

type PatchPromoReq struct {
	Title              *string                  `json:"title" binding:"omitempty,min=1,max=50"`
	Status             *entity.PromoStatusEnum  `json:"status" binding:"omitempty,oneof=visible hide"`
	Description        *string                  `json:"description" binding:"omitempty"`
	DiscountType       *entity.DiscountTypeEnum `json:"discount_type" binding:"omitempty,oneof=percentage fixed"`
	DiscountValue      *float64                 `json:"discount_value" binding:"omitempty,numeric,min=1"`
	UsageLimitCustomer *int64                   `json:"usage_limit_customer" binding:"omitempty,min=1"`
	MinMemberPoints    *int64                   `json:"min_member_points" binding:"omitempty,numeric,min=1"`
	StartAt            *time.Time               `json:"start_at" binding:"omitempty"`
	ExpiredAt          *time.Time               `json:"expired_at" binding:"omitempty"`
	ImageUrl           *string                  `json:"image_url" binding:"omitempty"`
}
