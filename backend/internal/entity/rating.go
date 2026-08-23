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
	ID        uuid.UUID      `db:"id"`
	IDBooking *uuid.UUID     `db:"id_booking"`
	IDUser    uuid.UUID      `db:"id_user"`
	IDStore   *uuid.UUID     `db:"id_store"`
	IDCapster *uuid.UUID     `db:"id_capster"`
	Type      RatingTypeEnum `db:"type"`
	Score     int16          `db:"score"`
	Message   *string        `db:"message"`
	CreatedAt time.Time      `db:"created_at"`
	UpdatedAt time.Time      `db:"updated_at"`
}
