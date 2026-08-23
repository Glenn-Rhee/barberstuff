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
	ID          uuid.UUID       `db:"id"`
	Name        string          `db:"name"`
	Address     *string         `db:"address"`
	Coordinate  *string         `db:"coordinate"`
	Description *string         `db:"description"`
	PhoneNumber *string         `db:"phone_number"`
	Status      StoreStatusEnum `db:"status"`
	ImageStore  []byte          `db:"image_store"`
	IDStaff     *uuid.UUID      `db:"id_staff"`
	CreatedAt   time.Time       `db:"created_at"`
	UpdatedAt   time.Time       `db:"updated_at"`
}