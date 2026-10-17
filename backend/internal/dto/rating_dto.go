package dto

import "github.com/google/uuid"

type Review struct {
	Id      uuid.UUID              `json:"id"`
	Message *string                `json:"message"`
	Rating  int16                  `json:"rating"`
	User    CustomerResponseRating `json:"user"`
}

type RatingCapsterRequest struct {
	Id    string `json:"id" binding:"required"`
	Score int    `json:"score" binding:"required,min=1,max=5"`
}

type RatingStaffRequest struct {
	Id    string `json:"id" binding:"required"`
	Score int    `json:"score" binding:"required,min=1,max=5"`
}

type RatingStoreRequest struct {
	Id      string  `json:"id" binding:"required"`
	Score   int     `json:"score" binding:"required,min=1,max=5"`
	Message *string `json:"message" binding:"omitempty"`
}

type RatingDataRequest struct {
	Capster *RatingCapsterRequest `json:"capster" binding:"omitempty"`
	Staff   *RatingStaffRequest   `json:"staff" binding:"omitempty"`
	Store   *RatingStoreRequest   `json:"store" binding:"omitempty"`
}

type CreateRatingRequest struct {
	IdBooking string            `json:"id_booking" binding:"required"`
	Rating    RatingDataRequest `json:"rating" binding:"required"`
}

type SortRating string

const (
	RatingByScore     SortRating = "score"
	RatingByCreatedAt SortRating = "created_at"
)

type GetRatingReq struct {
	IdTarget       *string     `form:"id_target" binding:"omitempty"`
	Query          *string     `form:"q" binding:"omitempty"`
	RatingMinScore *int        `form:"rating_score" binding:"omitempty,numeric,min=1,max=5"`
	RatingMaxScore *int        `form:"rating_score" binding:"omitempty,numeric,min=1,max=5"`
	SortBy         *SortRating `form:"sort_by" binding:"omitempty,oneof=score created_at"`
	RequestParamsPagination
}

type GetRatingRes struct {
	ID          uuid.UUID `json:"id"`
	IDCustomer  uuid.UUID `json:"id_customer"`
	Name        string    `json:"name"`
	PremiumType string    `json:"premium_type"`
	ImageUrl    *string   `json:"image_url"`
	Score       int       `json:"score"`
	Message     *string   `json:"message"`
}
