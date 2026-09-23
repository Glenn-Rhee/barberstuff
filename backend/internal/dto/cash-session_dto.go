package dto

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type CreateCashSession struct {
	SaldoBegin float64 `json:"saldo_begin" binding:"required,min=1000"`
}

type CreateCashSessionResponse struct {
	Id         uuid.UUID       `json:"id"`
	SaldoBegin decimal.Decimal `json:"saldo_begin"`
}

type GetCashSessionResponse struct {
	Id                  uuid.UUID             `json:"id"`
	SaldoBegin          decimal.Decimal       `json:"saldo_begin"`
	TotalIncomeCash     decimal.Decimal       `json:"total_income_cash"`
	TotalIncomeCashless decimal.Decimal       `json:"total_income_cashless"`
	TotalOutcome        decimal.Decimal       `json:"total_outcome"`
	Transactions        []TransactionResponse `json:"transactions"`
}

type TransactionResponse struct {
	Id              uuid.UUID              `json:"id"`
	Title           string                 `json:"title"`
	PaymentType     entity.PaymentType     `json:"payment_type"`
	Amount          decimal.Decimal        `json:"amount"`
	TransactionType entity.TransactionType `json:"transaction_type"`
	Description     *string                `json:"description"`
	CreatedAt       time.Time              `json:"created_at"`
}

type CloseCashSessionRequest struct {
	IdCashSession string  `json:"id_cash_session" binding:"required"`
	AmountActual  float64 `json:"amount_actual" binding:"required,min=1000"`
}

type StatusCloseCash string

const (
	StatusBalance  StatusCloseCash = "balance"
	StatusPositive StatusCloseCash = "positive"
	StatusMinus    StatusCloseCash = "minus"
)

type CloseCashSessionResponse struct {
	AmountDifference decimal.Decimal `json:"amount_difference"`
	Status           StatusCloseCash `json:"status"`
}
