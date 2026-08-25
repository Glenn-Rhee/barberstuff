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
	ID         uuid.UUID  `gorm:"column:id;primaryKey"`
	IDCustomer *uuid.UUID `gorm:"column:id_customer"`
	IDStaff    *uuid.UUID `gorm:"column:id_staff"`
	Password   string     `gorm:"column:password;not null"`
	Role       RoleEnum   `gorm:"column:role;not null"`
	Email      string     `gorm:"column:email;not null;unique"`
	CreatedAt  time.Time  `gorm:"column:created_at;not null"`
}

func (Authentication) TableName() string {
	return "authentication"
}