package entity

import (
	"time"

	"github.com/google/uuid"
)

type RoleEnum string

const (
	RoleCustomer RoleEnum = "customer"
	RoleCashier  RoleEnum = "cashier"
	RoleAdmin    RoleEnum = "admin"
	RoleOwner    RoleEnum = "owner"
)

type Authentication struct {
	ID         uuid.UUID  `db:"id"`
	IDCustomer *uuid.UUID `db:"id_customer"`
	IDStaff    *uuid.UUID `db:"id_staff"`
	Password   string     `db:"password"`
	Role       RoleEnum   `db:"role"`
	Email      string     `db:"email"`
	CreatedAt  time.Time  `db:"created_at"`
}
