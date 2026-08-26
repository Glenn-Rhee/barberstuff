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
