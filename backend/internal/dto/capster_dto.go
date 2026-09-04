package dto

import (
	"barberstuff_backend/internal/entity"

	"github.com/google/uuid"
)

type CapsterDataResponse struct {
	Id        uuid.UUID                `json:"id"`
	Name      string                   `json:"name"`
	Title     string                   `json:"title"`
	Status    entity.CapsterStatusEnum `json:"status"`
	ImageUrl  string                   `json:"image_url"`
	AvgRating float64                  `json:"avg_rating"`
}
