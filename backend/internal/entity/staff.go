package entity

import (
	"time"

	"github.com/google/uuid"
)

type Staff struct {
	ID        uuid.UUID `gorm:"column:id;primaryKey"`
	Name      string    `gorm:"column:name;not null"`
	CreatedAt time.Time `gorm:"column:created_at;not null"`
	UpdatedAt time.Time `gorm:"column:updated_at;not null"`
}

func (Staff) TableName() string {
	return "staff"
}