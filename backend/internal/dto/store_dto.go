package dto

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
)

type NewStoreRequest struct {
	Name        string    `json:"name" binding:"required"`
	Description *string   `json:"description"`
	Address     string    `json:"address" binding:"required"`
	BannerUrl   string    `json:"banner_url" binding:"required,url"`
	OpenHour    time.Time `json:"open_hour" binding:"required"`
	CloseHour   time.Time `json:"close_hour" binding:"required"`
	Lat         float64   `json:"lat" binding:"required"`
	Long        float64   `json:"long" binding:"required"`
	PhoneNumber string    `json:"phone_number" binding:"required,min=9,max=15"`
}

type UpdateStoreRequest struct {
	NewStoreRequest
	Status entity.StoreStatusEnum `json:"status" binding:"required,oneof=open close"`
}

type StoreData struct {
	Id          uuid.UUID  `json:"id"`
	Name        string     `json:"name"`
	PhoneNumber string     `json:"phone_number"`
	Coordinate  string     `json:"coordinate"`
	OpenHour    time.Time  `json:"open_hour"`
	CloseHour   time.Time  `json:"close_hour"`
	BannerUrl   string     `json:"banner_url"`
	Address     string     `json:"address"`
	Description string     `json:"description"`
	CreatedAt   time.Time  `json:"created_at"`
	DeletedAt   *time.Time `json:"deleted_at"`
}

type StoreResponse struct {
	Store   StoreData             `json:"store"`
	Service []ServiceData         `json:"service"`
	Package []PackageData         `json:"package"`
	Rating  RatingResponseData    `json:"rating"`
	Capster []CapsterDataResponse `json:"capster"`
}

func ToStoreResponse(store entity.Store) StoreData {
	return StoreData{
		Id:          store.ID,
		Name:        store.Name,
		PhoneNumber: derefString(store.PhoneNumber),
		Coordinate:  derefString(store.Coordinate),
		OpenHour:    store.OpenHour,
		CloseHour:   store.CloseHour,
		BannerUrl:   derefString(store.BannerUrl),
		Address:     derefString(store.Address),
		Description: derefString(store.Description),
		CreatedAt:   store.CreatedAt,
	}
}

func ToStoreResponseList(stores []entity.Store) []StoreData {
	responses := make([]StoreData, 0, len(stores))
	for _, s := range stores {
		responses = append(responses, ToStoreResponse(s))
	}
	return responses
}

// helper untuk convert *string -> string, aman dari nil
func derefString(s *string) string {
	if s == nil {
		return ""
	}
	return *s
}

type QueryParamsStores struct {
	NameStore *string `form:"name"`
}
