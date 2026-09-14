package dto

import "github.com/google/uuid"

type Review struct {
	Id      uuid.UUID              `json:"id"`
	Message string                 `json:"message"`
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
