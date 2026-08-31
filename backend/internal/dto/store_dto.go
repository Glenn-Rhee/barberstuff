package dto

import "time"

type NewStoreRequest struct {
	Name        string    `json:"name" binding:"required"`
	Description *string   `json:"description"`
	Address     string    `json:"alamat" binding:"required"`
	BannerUrl   string    `json:"banner_url" binding:"required,url"`
	OpenHour    time.Time `json:"open_hour" binding:"required"`
	CloseHour   time.Time `json:"close_hour" binding:"required"`
	Lat         float64   `json:"lat" binding:"required"`
	Long        float64   `json:"long" binding:"required"`
	PhoneNumber string    `json:"phone_number" binding:"required,min=9,max=15"`
}
