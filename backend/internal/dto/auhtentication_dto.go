package dto

import "barberstuff_backend/internal/entity"

type CredentialLoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=5"`
}

type UserAuth struct {
	UserId string          `json:"user_id"`
	Email  string          `json:"email"`
	Role   entity.RoleEnum `json:"role"`
}

type CredentialLoginResponse struct {
	AccessToken string   `json:"access_token"`
	ExpiresIn   int      `json:"expires_in"`
	User        UserAuth `json:"user"`
}

type Provider string

const (
	Google Provider = "google"
)

type AuthProviderRequest struct {
	IdToken  string   `json:"id_token" binding:"required"`
	Provider Provider `json:"provider" binding:"oneof=google"`
}

type StatusAuth string

const (
	NEED_COMPLETE_PROFILE StatusAuth = "NEED_COMPLETE_PROFILE"
	SUCCESS               StatusAuth = "SUCCESS"
)

type AuthProviderResponse struct {
	Email       string     `json:"email"`
	Name        string     `json:"name"`
	Status      StatusAuth `json:"status"`
	AccessToken string     `json:"access_token,omitempty"`
	TempToken   string     `json:"temp_token,omitempty"`
}
