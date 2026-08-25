package dto

import (
	"barberstuff_backend/internal/entity"
	"time"
)

type LoginType string

const (
	LoginWithOAuth      LoginType = "OAuth"
	LoginWithCredential LoginType = "Credential"
)

type CreateCustomerRequest struct {
	Name        string        `json:"name" validate:"required"`
	PhoneNumber string        `json:"phoneNumber" validate:"required,numeric,min=9,max=15"`
	DateOfBirth time.Time     `json:"date_of_birth" validate:"required"`
	Gender      entity.Gender `json:"gender" validate:"reqired"`
	Username    string        `json:"username" validate:"required,gt=5"`
	Email       string        `json:"email" validate:"required,email"`
	LoginType   LoginType     `json:"login_type" validate:"required"`
	Password    string        `json:"password" validate:"required"`
}

type CreateCustomerResponse struct {
	Id       string `json:"id"`
	Username string `json:"username"`
	Email    string `json:"email"`
}
