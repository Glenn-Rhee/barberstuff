package dto

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
)

type CapsterDataResponse struct {
	Id        uuid.UUID                `json:"id"`
	Name      string                   `json:"name"`
	Status    entity.CapsterStatusEnum `json:"status"`
	ImageUrl  string                   `json:"image_url"`
	AvgRating float64                  `json:"avg_rating"`
	IdStore   uuid.UUID                `json:"id_store"`
	CreatedAt time.Time                `json:"created_at"`
}

type CreateCapsterRequest struct {
	IdStore  string `json:"id_store" binding:"required"`
	Name     string `json:"name" binding:"required,min=3"`
	ImageUrl *string `json:"image_url" binding:"omitempty,url"`
}

type SortCapster string

const (
	CapsterByName      SortCapster = "name"
	CapsterByCreatedAt SortCapster = "created_at"
)

type QueryParamsCapsters struct {
	IdStore     string       `form:"id_store" binding:"required"`
	CapsterName *string      `form:"name"`
	SortBy      *SortCapster `form:"sort_by" binding:"omitempty,oneof=name created_at"`
	RequestParamsPagination
}

type UpdateCapsterRequest struct {
	Name     *string                   `json:"name" binding:"omitempty"`
	Status   *entity.CapsterStatusEnum `json:"status" binding:"omitempty,oneof=active inactive"`
	ImageUrl *string                   `json:"image_url" binding:"omitempty,url"`
	IdStore  *string                   `json:"id_store" binding:"omitempty"`
}
