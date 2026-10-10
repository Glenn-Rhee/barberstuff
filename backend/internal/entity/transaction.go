package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type PaymentType string

const (
	PaymentCash     PaymentType = "cash"
	PaymentCashless PaymentType = "cashless"
)

type TransactionType string

const (
	TransactionIncome  TransactionType = "income"
	TransactionOutcome TransactionType = "outcome"
)

type Transactions struct {
	ID              uuid.UUID       `gorm:"column:id;primaryKey"`
	IDCashSession   uuid.UUID       `gorm:"column:id_cash_session;not null"`
	IDBooking       *uuid.UUID      `gorm:"column:id_booking"`
	Title           string          `gorm:"column:title;not null"`
	PaymentType     PaymentType     `gorm:"column:payment_type;not null"`
	Amount          decimal.Decimal `gorm:"column:amount;not null"`
	TransactionType TransactionType `gorm:"column:transaction_type;not null"`
	Description     *string         `gorm:"column:description"`
	CreatedAt       time.Time       `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt       time.Time       `gorm:"column:updated_at;not null;autoUpdateTime"`
	DeletedAt       *time.Time      `gorm:"column:deleted_at"`
}

func (Transactions) TableName() string {
	return "transactions"
}
