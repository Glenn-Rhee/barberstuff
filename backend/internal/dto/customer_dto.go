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
	Email       string        `json:"email" binding:"required,email"`
	Password    string        `json:"password" binding:"required,min=5"`
}

type CredentialCustomerResponse struct {
	Id    string `json:"id"`
	Email string `json:"email"`
}

type OauthCustomerRequest struct {
	Name        string        `json:"name" binding:"required"`
	TempToken   string        `json:"temp_token" binding:"required"`
	PhoneNumber string        `json:"phoneNumber" binding:"required,min=9,max=15"`
	DateOfBirth time.Time     `json:"date_of_birth" binding:"required"`
	Gender      entity.Gender `json:"gender" binding:"required,oneof=male female"`
}

type VerifyCredentialRequest struct {
	UserId string `json:"user_id" binding:"required"`
	OTP    string `json:"otp" binding:"required,len=6,numeric"`
}

type GoogleClaims struct {
	Sub           string  `json:"sub"`
	Email         string  `json:"email"`
	EmailVerified bool    `json:"email_verified"`
	Name          string  `json:"name"`
	GivenName     string  `json:"given_name"`
	FamilyName    string  `json:"family_name"`
	Picture       string  `json:"picture"`
	Iss           string  `json:"iss"`
	Aud           string  `json:"aud"`
	Iat           float64 `json:"iat"`
	Exp           float64 `json:"exp"`
}

type ForgotPasswordRequest struct {
	Email string `json:"email" binding:"required,email"`
}

type ForgotPassswordResponse struct {
	Email     string `json:"email"`
	TempToken string `json:"temp_token"`
}
