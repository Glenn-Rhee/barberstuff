package entity

import (
	"time"

	"github.com/google/uuid"
)

type PremiumType struct {
	ID        uuid.UUID `gorm:"column:id;primaryKey"`
	Name      string    `gorm:"column:name;not null;unique"`
	CreatedAt time.Time `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt time.Time `gorm:"column:updated_at;not null;autoUpdateTime"`
}

func (PremiumType) TableName() string {
	return "premium_type"
}
