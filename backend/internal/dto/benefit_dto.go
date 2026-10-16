package dto

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
)

type CreateBenefitReq struct {
	Title       string                   `json:"title" binding:"required,min=1"`
	Description string                   `json:"description" binding:"required,min=1"`
	ImageUrl    string                   `json:"image_url" binding:"required"`
	Status      entity.BenefitStatusEnum `json:"status" binding:"required,oneof=visible hide"`
}

type SortBenefitEnum string

const (
	SortBenefitTitle     SortBenefitEnum = "title"
	SortBenefitStatus    SortBenefitEnum = "status"
	SortBenefitCreatedAt SortBenefitEnum = "created_at"
)

type GetBenefitReq struct {
	Query  *string                   `form:"q" binding:"omitempty"`
	Status *entity.BenefitStatusEnum `form:"status" binding:"omitempty,oneof=visible hide"`
	SortBy *SortBenefitEnum          `form:"sort_by" binding:"omitempty,oneof=title status created_at"`
	RequestParamsPagination
}

type GetBenefitRes struct {
	ID          uuid.UUID                 `json:"id"`
	Title       string                    `json:"title"`
	Description string                    `json:"description"`
	ImageUrl    *string                   `json:"image_url"`
	Status      *entity.BenefitStatusEnum `json:"status,omitempty"`
	CreatedAt   time.Time                 `json:"created_at"`
}

type PatchBenefitReq struct {
	Title       *string                   `json:"title" binding:"omitempty,min=1"`
	Description *string                   `json:"description" binding:"omitempty,min=1"`
	ImageUrl    *string                   `json:"image_url" binding:"omitempty"`
	Status      *entity.BenefitStatusEnum `json:"status" binding:"omitempty,oneof=visible hide"`
}
