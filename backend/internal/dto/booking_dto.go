package dto

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type LockBookingRequest struct {
	IdStore     string    `json:"id_store" binding:"required"`
	BookingDate time.Time `json:"booking_date" binding:"required"`
	IdCapster   string    `json:"id_capster" binding:"required"`
}

type CreateBookingRequest struct {
	IdService      string  `json:"id_service" binding:"required"`
	IdPromoClaimed *string `json:"id_promo_claimed" binding:"omitempty"`
	LockBookingRequest
}

type GetBookingStoreRequest struct {
	Date    time.Time `form:"date" binding:"required"`
	IdStore string    `form:"id_store" binding:"required"`
}

type DeleteLockBookingRequest struct {
	IdStore     string    `form:"id_store" binding:"required"`
	BookingDate time.Time `form:"booking_date" binding:"required"`
	IdCapster   string    `form:"id_capster" binding:"required"`
}

type CapsterAvailable struct {
	Id        uuid.UUID `json:"id"`
	Name      string    `json:"name"`
	AvgRating float64   `json:"avg_rating"`
	ImageUrl  string    `json:"image_url"`
	Available bool      `json:"available"`
}

type SlotAvailable struct {
	Time      string             `json:"time"`
	Available bool               `json:"available"`
	Capsters  []CapsterAvailable `json:"capsters"`
}

type GetBookingStoreResponse struct {
	IdStore uuid.UUID       `json:"id_store"`
	Date    time.Time       `json:"date"`
	Slots   []SlotAvailable `json:"slots"`
}

type DataStoreBooking struct {
	Id          uuid.UUID `json:"id"`
	Name        string    `json:"name"`
	Address     *string   `json:"address"`
	PhoneNumber *string   `json:"phone_number"`
}

type DataCapsterBooking struct {
	Id   uuid.UUID `json:"id"`
	Name string    `json:"name"`
}

type DataStaffBooking struct {
	Id   uuid.UUID `json:"id"`
	Name string    `json:"name"`
}

type DataServiceBooking struct {
	Id    uuid.UUID       `json:"id"`
	Name  string          `json:"name"`
	Price decimal.Decimal `json:"price"`
}

type CreateBookingResponse struct {
	IdBooking     uuid.UUID            `json:"id_booking"`
	QrCode        string               `json:"qr_code"`
	BookingDate   time.Time            `json:"booking_date"`
	AppServiceFee *int64               `json:"app_service_fee,omitempty"`
	TotalPrice    decimal.Decimal      `json:"total_price"`
	Store         DataStoreBooking     `json:"store"`
	Capster       DataCapsterBooking   `json:"capster"`
	Service       []DataServiceBooking `json:"service"`
}

type StatusBookingRequest string

const (
	StatusUpcoming StatusBookingRequest = "upcoming"
	StatusDone     StatusBookingRequest = "done"
	StatusCancel   StatusBookingRequest = "cancel"
)

type SortBooking string

const (
	SortByBookingDate        SortBooking = "scheduled_at"
	SortByBookingServiceName SortBooking = "name"
)

type GetBookingUserRequest struct {
	StatusBooking StatusBookingRequest `form:"status_booking" binding:"required,oneof=upcoming done cancel"`
	Query         *string              `form:"q" binding:"omitempty"`
	SortBy        *SortBooking         `form:"sort_by" binding:"omitempty,oneof=scheduled_at name"`
	RequestParamsPagination
}

type DataRatingBooking struct {
	AvgRating     float64 `json:"avg_rating"`
	CapsterRating int     `json:"capster_rating"`
	StaffRating   int     `json:"staff_rating"`
	StoreRating   int     `json:"store_rating"`
	Message       *string `json:"message"`
}

type GetBookingUserResponse struct {
	Id          uuid.UUID            `json:"id"`
	Service     []DataServiceBooking `json:"service"`
	Capster     DataCapsterBooking   `json:"capster"`
	Store       DataStoreBooking     `json:"store"`
	Staff       DataStaffBooking     `json:"staff"`
	BookingDate time.Time            `json:"booking_date"`
	TotalPrice  decimal.Decimal      `json:"total_price"`
	Rating      *DataRatingBooking   `json:"rating"`
}

// Data booking yang diambil oleh kasir
type GetBookingsRequest struct {
	Query         *string                   `form:"q" binding:"omitempty"`
	StatusBooking *entity.BookingStatusEnum `form:"status_booking" binding:"omitempty,oneof=booked progress completed canceled"`
	SortBy        *SortBooking              `form:"sort_by" binding:"omitempty,oneof=scheduled_at name"`
	RequestParamsPagination
}

// Data Booking yang diberikan ke kasir
type GetBookingsResponse struct {
	Customer CustomerBookings `json:"customer"`
	Booking  DataBooking      `json:"booking"`
}

// Untuk kasir
type CustomerBookings struct {
	Id              uuid.UUID `json:"id"`
	Name            string    `json:"name"`
	PhoneNumber     *string   `json:"phone_number"`
	PremiumType     string    `json:"premium_type"`
	MemberPoints    int64     `json:"member_points"`
	ServiceFavorite string    `json:"service_favorite"`
}

type DataBooking struct {
	Id             uuid.UUID                `json:"id"`
	ScheduledAt    time.Time                `json:"scheduled_at"`
	Capster        CapsterBookings          `json:"capster"`
	SubTotal       decimal.Decimal          `json:"sub_total"`
	DiscountAmount decimal.Decimal          `json:"discount_amount"`
	TotalPrice     decimal.Decimal          `json:"total_price"`
	Status         entity.BookingStatusEnum `json:"status_booking"`
	Services       []DataServiceBooking     `json:"services"`
	Notes          *string                  `json:"notes"`
}

// Untuk kasir
type CapsterBookings struct {
	AvgRating float32 `json:"avg_rating"`
	DataCapsterBooking
}
