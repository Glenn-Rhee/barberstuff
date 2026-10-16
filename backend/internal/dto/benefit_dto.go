package dto

import "barberstuff_backend/internal/entity"

type CreateBenefitReq struct {
	Title       string                   `json:"title" binding:"required,min=1"`
	Description string                   `json:"description" binding:"required,min=1"`
	ImageUrl    string                   `json:"image_url" binding:"required"`
	Status      entity.BenefitStatusEnum `json:"status" binding:"required,oneof=visible hide"`
}
