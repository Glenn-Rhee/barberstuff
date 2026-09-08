package dto

import "time"

type LockBookingRequest struct {
	IdStore     string    `json:"id_store" binding:"required"`
	BookingDate time.Time `json:"booking_date" binding:"required"`
	IdCapster   string    `json:"id_capster" binding:"required"`
}
