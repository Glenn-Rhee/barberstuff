package entity

import (
	"time"

	"github.com/google/uuid"
)

type Staff struct {
	ID             uuid.UUID      `gorm:"column:id;primaryKey"`
	Name           string         `gorm:"column:name;not null"`
	IdStore        *uuid.UUID     `gorm:"column:id_store"`
	CreatedAt      time.Time      `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt      time.Time      `gorm:"column:updated_at;not null;autoUpdateTime"`
	DeletedAt      time.Time      `gorm:"column:deleted_at"`
	Authentication Authentication `gorm:"foreignKey:IDStaff"`
}

func (Staff) TableName() string {
	return "staff"
}
