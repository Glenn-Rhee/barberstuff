package dto

type CreateCashSession struct {
	SaldoBegin float64 `json:"saldo_begin" binding:"required,min=1000"`
}
