package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type CashSessionType string

const (
	SessionOpen   CashSessionType = "open"
	SessionClosed CashSessionType = "closed"
)

type CashSession struct {
	ID           uuid.UUID        `gorm:"column:id;primaryKey"`
	IDStore      uuid.UUID        `gorm:"column:id_store;not null"`
	SaldoBegin   decimal.Decimal  `gorm:"column:saldo_begin;not null"`
	AmountActual *decimal.Decimal `gorm:"column:amount_actual"`
	Status       CashSessionType  `gorm:"column:status;not null;default:open"`
	ClosedAt     *time.Time       `gorm:"column:closed_at"`
	CreatedAt    time.Time        `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt    time.Time        `gorm:"column:updated_at;not null;autoUpdateTime"`
}

func (CashSession) TableName() string {
	return "cash_session"
}
