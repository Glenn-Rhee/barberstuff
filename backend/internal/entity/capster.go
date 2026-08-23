package entity

import (
	"time"

	"github.com/google/uuid"
)

type CapsterStatusEnum string

const (
	CapsterStatusActive   CapsterStatusEnum = "active"
	CapsterStatusInactive CapsterStatusEnum = "inactive"
)

type Capster struct {
	ID           uuid.UUID         `db:"id"`
	Name         string            `db:"name"`
	ImageCapster []byte            `db:"image_capster"`
	Status       CapsterStatusEnum `db:"status"`
	IDStore      uuid.UUID         `db:"id_store"`
	CreatedAt    time.Time         `db:"created_at"`
	UpdatedAt    time.Time         `db:"updated_at"`
}
