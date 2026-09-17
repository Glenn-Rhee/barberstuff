package dto

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
)

type CredentialCustomerRequest struct {
	Name        string        `json:"name" binding:"required,min=1"`
	PhoneNumber string        `json:"phoneNumber" binding:"required,min=9,max=15"`
	DateOfBirth time.Time     `json:"date_of_birth" binding:"required"`
	Gender      entity.Gender `json:"gender" binding:"required,oneof=male female"`
	Email       string        `json:"email" binding:"required,email"`
	Password    string        `json:"password" binding:"required,min=5"`
	ImageUrl    *string       `json:"image_url" binding:"omitempty,url"`
}

type CredentialCustomerResponse struct {
	Id    string `json:"id"`
	Email string `json:"email"`
}

type OauthCustomerRequest struct {
	Name        string        `json:"name" binding:"required,min=1"`
	TempToken   string        `json:"temp_token" binding:"required"`
	PhoneNumber string        `json:"phoneNumber" binding:"required,min=9,max=15"`
	DateOfBirth time.Time     `json:"date_of_birth" binding:"required"`
	Gender      entity.Gender `json:"gender" binding:"required,oneof=male female"`
	ImageUrl    *string       `json:"image_url" binding:"omitempty,url"`
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
	UserId string `json:"user_id"`
}

type VerifyOTPResponse struct {
	ResetToken string `json:"reset_token,omitempty"`
}

type CustomerResponseRating struct {
	Id          uuid.UUID `json:"id"`
	Name        string    `json:"name"`
	ImageUrl    *string   `json:"image_url"`
	PremiumType string    `json:"premium_type"`
}

type ProfileCustomerResponse struct {
	Id            uuid.UUID        `json:"id"`
	Name          string           `json:"name"`
	PhoneNumber   string           `json:"phone_number"`
	DateOfBirth   time.Time        `json:"date_of_birth"`
	Gender        entity.Gender    `json:"gender"`
	MemberPoints  int              `json:"member_points"`
	PremiumType   string           `json:"premium_type"`
	ImageUrl      *string          `json:"image_url"`
	CreatedAt     time.Time        `json:"created_at"`
	Role          entity.RoleEnum  `json:"role"`
	Email         string           `json:"email"`
	IsVerified    bool             `json:"is_verified"`
	LoginType     entity.LoginType `json:"login_type"`
	OauthProvider string           `json:"oauth_provider"`
}

type UpdateProfileRequest struct {
	Name        *string `json:"name" binding:"omitempty,min=1"`
	ImageUrl    *string `json:"image_url" binding:"omitempty,url"`
	PhoneNumber *string `json:"phoneNumber" binding:"omitempty,min=9,max=15"`
}

type SortCustomer string

const (
	SortByCustomerName         SortCustomer = "name"
	SortByCustomerCreatedAt    SortCustomer = "created_at"
	SortByCustomerMemberPoints SortCustomer = "member_points"
	SortByCustomerEmail        SortCustomer = "email"
)

type FindCustomerRequest struct {
	Query  *string       `form:"q" binding:"omitempty"`
	SortBy *SortCustomer `form:"sort_by" binding:"omitempty,oneof=name created_at member_points email"`
	RequestParamsPagination
}

type StatusCustomer string

const (
	StatusMember  StatusCustomer = "MEMBER"
	StatusReguler StatusCustomer = "REGULER"
)

type DataUserFindCustomer struct {
	Id              uuid.UUID      `json:"id"`
	Name            string         `json:"name"`
	PhoneNumber     *string        `json:"phone_number"`
	MemberPoints    int64          `json:"member_points"`
	Status          StatusCustomer `json:"status"`
	TotalVisited    int64          `json:"total_visited"`
	LastVisitedAt   *time.Time     `json:"last_visited_at"`
	ServiceFavorite string         `json:"service_favorite"`
	CapsterFavorite string         `json:"capster_favorite"`
	ImageUrl        *string        `json:"image_url"`
	Email           string         `json:"email"`
}

type DataKPICustomer struct {
	TotalCustomers    int64 `json:"total_customers"`
	TotalMembers      int64 `json:"total_members"`
	TotalNewCustomers int64 `json:"total_new_customers"`
}

type FindCustomerResponse struct {
	Customers []DataUserFindCustomer `json:"customers"`
	KPI       DataKPICustomer        `json:"kpi"`
}
