package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type BookingStatusEnum string

const (
	BookingStatusOngoing   BookingStatusEnum = "ongoing"
	BookingStatusCompleted BookingStatusEnum = "completed"
	BookingStatusCanceled  BookingStatusEnum = "canceled"
)

type Booking struct {
	ID             uuid.UUID         `db:"id"`
	StatusBooking  BookingStatusEnum `db:"status_booking"`
	IDStore        uuid.UUID         `db:"id_store"`
	IDUser         uuid.UUID         `db:"id_user"`
	IDCapster      *uuid.UUID        `db:"id_capster"`
	IDService      *uuid.UUID        `db:"id_service"`
	IDPackage      *uuid.UUID        `db:"id_package"`
	IDPromoClaimed *uuid.UUID        `db:"id_promo_claimed"`
	TotalPrice     decimal.Decimal   `db:"total_price"`
	ScheduledAt    *time.Time        `db:"scheduled_at"`
	QRCode         *string           `db:"qr_code"`
	CreatedAt      time.Time         `db:"created_at"`
	UpdatedAt      time.Time         `db:"updated_at"`
}


type BookingStatusHistory struct {
	ID         uuid.UUID          `db:"id"`
	IDBooking  uuid.UUID          `db:"id_booking"`
	OldStatus  *BookingStatusEnum `db:"old_status"`
	NewStatus  BookingStatusEnum  `db:"new_status"`
	ChangedBy  *uuid.UUID         `db:"changed_by"`
	CreatedAt  time.Time          `db:"created_at"`
}