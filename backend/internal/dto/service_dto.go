package dto

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type GetServiceResponse struct {
	Id          uuid.UUID                `json:"id"`
	Name        string                   `json:"name"`
	Price       decimal.Decimal          `json:"price"`
	Description *string                  `json:"description"`
	Status      entity.ProductStatusEnum `json:"status"`
	IdStore     uuid.UUID                `json:"id_store"`
	Type        entity.ProductTypeEnum   `json:"type"`
	CreatedAt   time.Time                `json:"created_at"`
	ImgUrl      *string                  `json:"image_url"`
}

type SortService string

const (
	ServiceByName      SortService = "name"
	ServiceByPrice     SortService = "price"
	ServiceByCreatedAt SortService = "created_at"
)

type QueryParamsService struct {
	IdStore     *string                 `form:"id_store" binding:"omitempty"`
	Type        *entity.ProductTypeEnum `form:"type" binding:"omitempty,oneof=service package product"`
	ServiceName *string                 `form:"name" binding:"omitempty"`
	SortBy      *SortService            `form:"sort_by" binding:"omitempty,oneof=name price created_at"`
	RequestParamsPagination
}

type CreateServiceRequest struct {
	Name        string                 `json:"name" binding:"required"`
	Price       float64                `json:"price" binding:"required,min=1000"`
	Description *string                `json:"description" binding:"omitempty"`
	IdStore     string                 `json:"id_store" binding:"required"`
	Type        entity.ProductTypeEnum `json:"type" binding:"required,oneof=service package product"`
	ImgUrl      *string                `json:"image_url" binding:"omitempty"`
}

type UpdateServiceRequest struct {
	Name        *string                   `json:"name" binding:"omitempty"`
	Price       *float64                  `json:"price" binding:"omitempty,min=1000"`
	Description *string                   `json:"description" binding:"omitempty"`
	Status      *entity.ProductStatusEnum `json:"status" binding:"omitempty,oneof=active inactive"`
	ImgUrl      *string                   `json:"image_url" binding:"omitempty"`
}
