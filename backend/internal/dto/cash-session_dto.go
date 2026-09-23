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
	StatusBalance StatusCloseCash = "balance"
	StatusOver    StatusCloseCash = "over"
	StatusShort   StatusCloseCash = "short"
)

type CloseCashSessionResponse struct {
	AmountDifference decimal.Decimal `json:"amount_difference"`
	Status           StatusCloseCash `json:"status"`
}

type HistoryCashSessionReq struct {
	Date    *time.Time `form:"date" binding:"omitempty"`
	Query   *string    `form:"q" binding:"omitempty"`
	IdStore *string    `form:"id_store" binding:"omitempty"`
	RequestParamsPagination
}

type CashSessionStore struct {
	Id        uuid.UUID `json:"id"`
	Name      string    `json:"name"`
	CloseHour time.Time `json:"close_hour"`
	OpenHour  time.Time `json:"open_hour"`
}

type CashSessionStaff struct {
	Id   uuid.UUID `json:"id"`
	Name string    `json:"name"`
}

type HistoryCashSessionRes struct {
	IdCashSession       uuid.UUID        `json:"id_cash_session"`
	SaldoBegin          decimal.Decimal  `json:"saldo_begin"`
	AmountActual        decimal.Decimal  `json:"amount_actual"`
	AmountDifference    decimal.Decimal  `json:"amount_difference"`
	TotalIncomeCash     decimal.Decimal  `json:"total_income_cash"`
	TotalIncomeCashless decimal.Decimal  `json:"total_income_cashless"`
	TotalOutcome        decimal.Decimal  `json:"total_outcome"`
	Status              StatusCloseCash  `json:"status"`
	CreatedAt           time.Time        `json:"created_at"`
	ClosedAt            *time.Time       `json:"closed_at"`
	Store               CashSessionStore `json:"store"`
	Staff               CashSessionStaff `json:"staff"`
}
