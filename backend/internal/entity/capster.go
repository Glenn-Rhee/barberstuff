package entity

import (
	"time"

	"github.com/google/uuid"
)

type CapsterStatusEnum string

const (
	CapsterStatusActive   CapsterStatusEnum = "active"
	CapsterStatusInactive CapsterStatusEnum = "inactive"
)

type Capster struct {
	ID           uuid.UUID         `gorm:"column:id;primaryKey"`
	Name         string            `gorm:"column:name;not null"`
	ImageCapster []byte            `gorm:"column:image_capster"`
	Status       CapsterStatusEnum `gorm:"column:status;not null"`
	IDStore      uuid.UUID         `gorm:"column:id_store;not null"`
	CreatedAt    time.Time         `gorm:"column:created_at;not null"`
	UpdatedAt    time.Time         `gorm:"column:updated_at;not null"`
}

func (Capster) TableName() string {
	return "capster"
}
