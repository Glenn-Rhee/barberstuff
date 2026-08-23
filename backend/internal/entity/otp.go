package entity

import (
	"time"

	"github.com/google/uuid"
)

type OTP struct {
	ID        uuid.UUID `db:"id"`
	IDUser    uuid.UUID `db:"id_user"`
	OTP       string    `db:"otp"`
	ExpiredAt time.Time `db:"expired_at"`
	CreatedAt time.Time `db:"created_at"`
}
