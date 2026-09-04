package dto

import (
	"barberstuff_backend/internal/entity"

	"github.com/google/uuid"
)

type CapsterDataResponse struct {
	Id        uuid.UUID                `json:"id"`
	Name      string                   `json:"name"`
	Status    entity.CapsterStatusEnum `json:"status"`
	ImageUrl  string                   `json:"image_url"`
	AvgRating float64                  `json:"avg_rating"`
}

type CreateCapsterRequest struct {
	IdStore  string `json:"id_store" binding:"required"`
	Name     string `json:"name" binding:"required,min=3"`
	ImageUrl string `json:"image_url" binding:"omitempty,url"`
}
