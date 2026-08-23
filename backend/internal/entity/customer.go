package entity

import (
	"time"

	"github.com/google/uuid"
)

type Customer struct {
	ID           uuid.UUID  `db:"id"`
	Name         string     `db:"name"`
	PhoneNumber  *string    `db:"phone_number"`
	DateOfBirth  *time.Time `db:"date_of_birth"`
	Gender       *string    `db:"gender"`
	Username     string     `db:"username"`
	MemberPoints int        `db:"member_points"`
	CreatedAt    time.Time  `db:"created_at"`
	UpdatedAt    time.Time  `db:"updated_at"`
}
