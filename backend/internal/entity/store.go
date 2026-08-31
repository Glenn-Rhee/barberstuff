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
	ID          uuid.UUID       `gorm:"column:id;primaryKey;default:gen_random_uuid()"`
	Name        string          `gorm:"column:name;not null"`
	PhoneNumber *string         `gorm:"column:phone_number"`
	Coordinate  *string         `gorm:"column:coordinate"`
	OpenHour    time.Time       `gorm:"column:open_hour;not null"`
	CloseHour   time.Time       `gorm:"column:close_hour;not null"`
	BannerUrl   *string         `gorm:"column:banner_url"`
	Address     *string         `gorm:"column:address"`
	Description *string         `gorm:"column:description"`
	Status      StoreStatusEnum `gorm:"column:status;not null;default:open"`
	CreatedAt   time.Time       `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time       `gorm:"column:updated_at;not null;autoUpdateTime"`
	DeletedAt   *time.Time      `gorm:"column:deleted_at"`
}

func (Store) TableName() string {
	return "store"
}
