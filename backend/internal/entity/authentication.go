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

type LoginType string

const (
	LoginWithOAuth      LoginType = "OAuth"
	LoginWithCredential LoginType = "Credential"
)

type Authentication struct {
	ID            uuid.UUID  `gorm:"column:id;primaryKey"`
	IDCustomer    *uuid.UUID `gorm:"column:id_customer"`
	IDStaff       *uuid.UUID `gorm:"column:id_staff"`
	Password      string     `gorm:"column:password;not null"`
	Role          RoleEnum   `gorm:"column:role;not null"`
	Email         string     `gorm:"column:email;not null;unique"`
	CreatedAt     time.Time  `gorm:"column:created_at;not null"`
	IsVerified    bool       `gorm:"column:is_verified;not null"`
	LoginType     LoginType  `gorm:"column:login_type;not null"`
	OAuthProvider string     `gorm:"column:oauth_provider;not null"`
}

func (Authentication) TableName() string {
	return "authentication"
}
