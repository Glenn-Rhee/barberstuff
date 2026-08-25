package entity

import (
	"time"

	"github.com/google/uuid"
)

type OTP struct {
	ID        uuid.UUID `gorm:"column:id;primaryKey"`
	IDUser    uuid.UUID `gorm:"column:id_user;not null;unique"`
	OTP       string    `gorm:"column:otp;not null"`
	ExpiredAt time.Time `gorm:"column:expired_at;not null"`
	CreatedAt time.Time `gorm:"column:created_at;not null"`
}

func (OTP) TableName() string {
	return "otp"
}