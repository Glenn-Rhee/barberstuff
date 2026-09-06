package dto

import "github.com/google/uuid"

type Review struct {
	Id      uuid.UUID              `json:"id"`
	Message string                 `json:"message"`
	Rating  int16                  `json:"rating"`
	User    CustomerResponseRating `json:"user"`
}
