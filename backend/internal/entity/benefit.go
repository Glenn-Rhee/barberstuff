package entity

import (
	"time"

	"github.com/google/uuid"
)

type BenefitStatusEnum string

const (
	BenefitStatusVisible BookingStatusEnum = "visible"
	BenefitStatusHide    BookingStatusEnum = "hide"
)

type Benefit struct {
	ID          uuid.UUID         `gorm:"column:id;primaryKey"`
	Title       string            `gorm:"column:title;not null"`
	Description string            `gorm:"column:description;not null"`
	ImageUrl    *string           `gorm:"column:image_url"`
	Status      BenefitStatusEnum `gorm:"column:status;not null;default:visible"`
	CreatedAt   time.Time         `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time         `gorm:"column:updated_at;not null;autoUpdateTime"`
}

func (Benefit) TableName() string {
	return "benefit"
}
