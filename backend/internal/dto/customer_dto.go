package dto

import (
	"barberstuff_backend/internal/entity"
	"time"
)

type CredentialCustomerRequest struct {
	Name        string        `json:"name" binding:"required"`
	PhoneNumber string        `json:"phoneNumber" binding:"required,min=9,max=15"`
	DateOfBirth time.Time     `json:"date_of_birth" binding:"required"`
	Gender      entity.Gender `json:"gender" binding:"required,oneof=male female"`
	Username    string        `json:"username" binding:"required,gt=5"`
	Email       string        `json:"email" binding:"required,email"`
	Password    string        `json:"password" binding:"required,min=5"`
}

type CredentialCustomerResponse struct {
	Id       string `json:"id"`
	Username string `json:"username"`
	Email    string `json:"email"`
}
