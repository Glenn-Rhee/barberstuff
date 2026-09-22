package dto

type CreateCashSession struct {
	IDstore    string  `json:"id_store" binding:"required"`
	SaldoBegin float64 `json:"saldo_begin" binding:"required,min=1000"`
}
