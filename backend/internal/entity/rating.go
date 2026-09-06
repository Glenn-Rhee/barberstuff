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
	ID        uuid.UUID      `gorm:"column:id;primaryKey"`
	IDUser    uuid.UUID      `gorm:"column:id_user;not null"`
	IDStore   *uuid.UUID     `gorm:"column:id_store"`
	IDCapster *uuid.UUID     `gorm:"column:id_capster"`
	IdStaff   *uuid.UUID     `gorm:"column:id_staff"`
	Type      RatingTypeEnum `gorm:"column:type;not null"`
	Score     int16          `gorm:"column:score;not null"`
	Message   *string        `gorm:"column:message"`
	CreatedAt time.Time      `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt time.Time      `gorm:"column:updated_at;not null;autoUpdateTime"`

	Customer Customer `gorm:"foreignKey:IDUser;references:ID"`
}

func (Rating) TableName() string {
	return "rating"
}
