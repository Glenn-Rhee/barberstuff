package dto

type CreatePositionReq struct {
	Name         string  `json:"name" binding:"required"`
	BasicSallary float64 `json:"basic_sallary" binding:"required,min=1000"`
}
