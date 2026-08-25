package entity

import (
	"time"

	"github.com/google/uuid"
)

type RatingTypeEnum string

const (
	RatingTypeStore   RatingTypeEnum = "store"
	RatingTypeCapster RatingTypeEnum = "capster"
)

type Rating struct {
	ID        uuid.UUID      `gorm:"column:id;primaryKey"`
	IDBooking *uuid.UUID     `gorm:"column:id_booking;unique"`
	IDUser    uuid.UUID      `gorm:"column:id_user;not null"`
	IDStore   *uuid.UUID     `gorm:"column:id_store"`
	IDCapster *uuid.UUID     `gorm:"column:id_capster"`
	Type      RatingTypeEnum `gorm:"column:type;not null"`
	Score     int16          `gorm:"column:score;not null"`
	Message   *string        `gorm:"column:message"`
	CreatedAt time.Time      `gorm:"column:created_at;not null"`
	UpdatedAt time.Time      `gorm:"column:updated_at;not null"`
}

func (Rating) TableName() string {
	return "rating"
}