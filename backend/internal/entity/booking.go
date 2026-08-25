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
	ID             uuid.UUID         `gorm:"column:id;primaryKey"`
	StatusBooking  BookingStatusEnum `gorm:"column:status_booking;not null"`
	IDStore        uuid.UUID         `gorm:"column:id_store;not null"`
	IDUser         uuid.UUID         `gorm:"column:id_user;not null"`
	IDCapster      *uuid.UUID        `gorm:"column:id_capster"`
	IDService      *uuid.UUID        `gorm:"column:id_service"`
	IDPackage      *uuid.UUID        `gorm:"column:id_package"`
	IDPromoClaimed *uuid.UUID        `gorm:"column:id_promo_claimed"`
	TotalPrice     decimal.Decimal   `gorm:"column:total_price;not null;default:0"`
	ScheduledAt    *time.Time        `gorm:"column:scheduled_at"`
	QRCode         *string           `gorm:"column:qr_code"`
	CreatedAt      time.Time         `gorm:"column:created_at;not null"`
	UpdatedAt      time.Time         `gorm:"column:updated_at;not null"`
}

func (Booking) TableName() string {
	return "booking"
}

type BookingStatusHistory struct {
	ID        uuid.UUID          `gorm:"column:id;primaryKey"`
	IDBooking uuid.UUID          `gorm:"column:id_booking;not null"`
	OldStatus *BookingStatusEnum `gorm:"column:old_status"`
	NewStatus BookingStatusEnum  `gorm:"column:new_status;not null"`
	ChangedBy *uuid.UUID         `gorm:"column:changed_by"`
	CreatedAt time.Time          `gorm:"column:created_at;not null"`
}

func (BookingStatusHistory) TableName() string {
	return "booking_status_history"
}