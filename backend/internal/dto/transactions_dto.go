package dto

import "barberstuff_backend/internal/entity"

type CreateTransactionReq struct {
	IDCashSession   string                 `json:"id_cash_session" binding:"required"`
	Title           *string                `json:"title" binding:"omitempty,min=1"`
	IdBooking       *string                `json:"id_booking" binding:"omitempty"`
	TransactionType entity.TransactionType `json:"transaction_type" binding:"required,oneof=income outcome"`
	PaymentType     *entity.PaymentType    `json:"payment_type" binding:"omitempty,oneof=cash cashless"`
	Amount          *float64               `json:"amount" binding:"omitempty,min=1000"`
	Description     *string                `json:"description" binding:"omitempty"`
	DiscountAmount  *float64               `json:"discount_amount" binding:"omitempty"`
}
