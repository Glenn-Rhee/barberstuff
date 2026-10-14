package entity

import (
	"time"

	"github.com/google/uuid"
)

type RatingTypeEnum string

const (
	RatingTypeStore   RatingTypeEnum = "store"
	RatingTypeCapster RatingTypeEnum = "capster"
	RatingTypeStaff   RatingTypeEnum = "staff"
)

type Rating struct {
	ID         uuid.UUID      `gorm:"column:id;primaryKey"`
	IDUser     uuid.UUID      `gorm:"column:id_user;not null"`
	IDBooking  uuid.UUID      `gorm:"column:id_booking;no null"`
	IDStore    *uuid.UUID     `gorm:"column:id_store"`
	IDEmployee *uuid.UUID     `gorm:"column:id_employee"`
	IdStaff    *uuid.UUID     `gorm:"column:id_staff"`
	Type       RatingTypeEnum `gorm:"column:type;not null"`
	Score      int16          `gorm:"column:score;not null"`
	Message    *string        `gorm:"column:message"`
	CreatedAt  time.Time      `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt  time.Time      `gorm:"column:updated_at;not null;autoUpdateTime"`
	Customer   Customer       `gorm:"foreignKey:IDUser;references:ID"`
	Store      *Store         `gorm:"foreignKey:IDStore"`
	Employee   *Employee      `gorm:"foreignKey:IDEmployee"`
	Staff      *Staff         `gorm:"foreignKey:IDStaff"`
}

func (Rating) TableName() string {
	return "rating"
}
