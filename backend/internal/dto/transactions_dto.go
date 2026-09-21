package dto

type CreateIncomeRequest struct {
	IdBooking string `json:"id_booking" binding:"required"`
	
}
