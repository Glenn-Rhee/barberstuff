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
