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
	ID        uuid.UUID         `gorm:"column:id;primaryKey"`
	Name      string            `gorm:"column:name;not null"`
	Status    CapsterStatusEnum `gorm:"column:status;not null"`
	ImageUrl  *string           `gorm:"column:image_url"`
	IDStore   uuid.UUID         `gorm:"column:id_store;not null"`
	CreatedAt time.Time         `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt time.Time         `gorm:"column:updated_at;not null;autoUpdateTime"`
	DeletedAt *time.Time        `gorm:"column:deleted_at"`
	Ratings   []Rating          `gorm:"foreignKey:IDCapster;references:ID"`
}

func (Capster) TableName() string {
	return "capster"
}
