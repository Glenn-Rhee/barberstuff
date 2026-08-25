package entity

import (
	"time"

	"github.com/google/uuid"
)

type StoreStatusEnum string

const (
	StoreStatusOpen  StoreStatusEnum = "open"
	StoreStatusClose StoreStatusEnum = "close"
)

type Store struct {
	ID          uuid.UUID       `gorm:"column:id;primaryKey"`
	Name        string          `gorm:"column:name;not null"`
	Address     *string         `gorm:"column:address"`
	Coordinate  *string         `gorm:"column:coordinate"`
	Description *string         `gorm:"column:description"`
	PhoneNumber *string         `gorm:"column:phone_number"`
	Status      StoreStatusEnum `gorm:"column:status;not null"`
	ImageStore  []byte          `gorm:"column:image_store"`
	IDStaff     *uuid.UUID      `gorm:"column:id_staff"`
	CreatedAt   time.Time       `gorm:"column:created_at;not null"`
	UpdatedAt   time.Time       `gorm:"column:updated_at;not null"`
}

func (Store) TableName() string {
	return "store"
}
