package dto

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
)

type StaffRequest struct {
	Name     string `json:"name" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=5"`
}

type CreateAccountStaffRequest struct {
	IdStore string          `json:"id_store" binding:"required"`
	Name    string          `json:"name" binding:"required,min=3"`
	Email   string          `json:"email" binding:"required,email"`
	Role    entity.RoleEnum `json:"role" binding:"required,oneof=cashier mitra"`
}

type QueryParamsAccountStaff struct {
	IdStore string  `form:"id_store"`
	Name    *string `form:"name"`
	Email   *string `form:"email" binding:"omitempty,email"`
}

type StaffAccountsResponse struct {
	Id        uuid.UUID       `json:"id"`
	Name      string          `json:"name"`
	IdStore   uuid.UUID       `json:"id_store"`
	Role      entity.RoleEnum `json:"role"`
	Email     string          `json:"email"`
	CreatedAt time.Time       `json:"created_at"`
	AvgRating float32         `json:"avg_rating"`
}

type UpdateAccountStaffRequest struct {
	Name     string `json:"name" binding:"required,min=3"`
	Password string `json:"password" binding:"required,min=5"`
}

type CustomerBookingCashier struct {
	Id          *string `json:"id" binding:"omitempty"`
	Name        *string `json:"name" binding:"omitempty"`
	PhoneNumber *string `json:"phoneNumber" binding:"omitempty,min=9,max=15"`
}

type BookingTypeCashier string

const (
	BookingTypeOrder   BookingTypeCashier = "order"
	BookingTypeBooking BookingTypeCashier = "booking"
)

// Create booking from cashire
type CreateCashireBookingRequest struct {
	IdStore     string                 `json:"id_store" binding:"required"`
	IdCapster   string                 `json:"id_capster" binding:"required"`
	IdServices  []string               `json:"id_services" binding:"required"`
	BookingDate time.Time              `json:"booking_date" binding:"required"`
	Customer    CustomerBookingCashier `json:"customer" binding:"required"`
	BookingType BookingTypeCashier     `json:"is_booking" binding:"required"`
}
