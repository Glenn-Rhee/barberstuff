package entity

import (
	"time"

	"github.com/google/uuid"
)

type TitleOutcome struct {
	ID        uuid.UUID `gorm:"column:id;primaryKey"`
	Name      string    `gorm:"column:name;not null"`
	CreatedAt time.Time `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt time.Time `gorm:"column:updated_at;not null;autoUpdateTime"`
}

func (TitleOutcome) TableName() string {
	return "title_outcome"
}
