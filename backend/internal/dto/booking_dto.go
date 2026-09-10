package dto

import (
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
	Address     string    `json:"address"`
	PhoneNumber string    `json:"phone_number"`
}

type DataCapsterBooking struct {
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
	AppServiceFee int64                `json:"app_service_fee"`
	TotalPrice    decimal.Decimal      `json:"total_price"`
	Store         DataStoreBooking     `json:"store"`
	Capster       DataCapsterBooking   `json:"capster"`
	Service       []DataServiceBooking `json:"service"`
}
