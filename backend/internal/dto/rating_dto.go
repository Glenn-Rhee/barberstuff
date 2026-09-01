package dto

import "github.com/google/uuid"

type RatingResponseData struct {
	AvgRating float64  `json:"avg_rating"`
	Review    []Review `json:"review"`
}

type Review struct {
	Id      uuid.UUID              `json:"id"`
	Message string                 `json:"message"`
	Rating  int16                  `json:"rating"`
	User    CustomerResponseRating `json:"user"`
}
