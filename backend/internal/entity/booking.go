package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type BookingStatusEnum string

const (
	BookingStatusBooked    BookingStatusEnum = "booked"
	BookingStatusProgress  BookingStatusEnum = "progress"
	BookingStatusCompleted BookingStatusEnum = "completed"
	BookingStatusCanceled  BookingStatusEnum = "canceled"
)

type BookingTypeEnum string

const (
	BookingScheduled BookingTypeEnum = "scheduled"
	BookingWalkIn    BookingTypeEnum = "walk_in"
)

type Booking struct {
	ID             uuid.UUID         `gorm:"column:id;primaryKey"`
	StatusBooking  BookingStatusEnum `gorm:"column:status_booking;not null"`
	IDStore        uuid.UUID         `gorm:"column:id_store;not null"`
	IDCustomer     uuid.UUID         `gorm:"column:id_user;not null"`
	IDCapster      uuid.UUID         `gorm:"column:id_capster"`
	IDStaff        uuid.UUID         `gorm:"column:id_staff;not null"`
	IDPromoClaimed *uuid.UUID        `gorm:"column:id_promo_claimed"`
	SubTotal       decimal.Decimal   `gorm:"column:subtotal;default:0"`
	DiscountAmount decimal.Decimal   `gorm:"column:discount_amount;default:0"`
	TotalPrice     decimal.Decimal   `gorm:"column:total_price;not null;default:0"`
	ScheduledAt    time.Time         `gorm:"column:scheduled_at"`
	QRCode         string            `gorm:"column:qr_code"`
	BookingType    BookingTypeEnum   `gorm:"column:booking_type;not null"`
	CreatedAt      time.Time         `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt      time.Time         `gorm:"column:updated_at;not null;autoUpdateTime"`
	BookingItems   []BookingItem     `gorm:"foreignKey:IDBooking"`
	Store          Store             `gorm:"foreignKey:IDStore"`
	Capster        Capster           `gorm:"foreignKey:IDCapster"`
	Staff          Staff             `gorm:"foreignKey:IDStaff"`
	Ratings        []Rating          `gorm:"foreignKey:IDBooking"`
}

func (Booking) TableName() string {
	return "booking"
}

type BookingItem struct {
	ID          uuid.UUID       `gorm:"column:id;primaryKey"`
	IDBooking   uuid.UUID       `gorm:"column:id_booking;not null"`
	IDService   uuid.UUID       `gorm:"column:id_service;not null"`
	Price       decimal.Decimal `gorm:"column:price;not null"`
	AddedOnSpot bool            `gorm:"column:added_on_spot;not null"`
	CreatedAt   time.Time       `gorm:"column:created_at;not null;autoCreateTime"`
	Service     Service         `gorm:"foreignKey:IDService"`
}

func (BookingItem) TableName() string {
	return "booking_item"
}
