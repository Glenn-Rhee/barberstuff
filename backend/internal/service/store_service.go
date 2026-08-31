package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/repository"
	"errors"
	"fmt"
	"runtime"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type StoreService interface {
	CreateNewStore(req dto.NewStoreRequest) error
}

type storeService struct {
	storeRepo repository.StoreRepository
}

func NewStoreService(storeRepo repository.StoreRepository) StoreService {
	return &storeService{
		storeRepo: storeRepo,
	}
}

func (s *storeService) CreateNewStore(req dto.NewStoreRequest) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat data toko!"
	_, filePath, _, _ := runtime.Caller(0)

	_, err := s.storeRepo.FindOne("name = ?", req.Name)
	if err == nil {
		return errors.New("Store name sudah tersedia! Anda tidak dapat menambahkannya kembali")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find data store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	coordinate := fmt.Sprintf("%f,%f", req.Lat, req.Long)
	store := entity.Store{
		ID:          uuid.New(),
		Name:        req.Name,
		PhoneNumber: &req.PhoneNumber,
		Coordinate:  &coordinate,
		OpenHour:    req.OpenHour,
		CloseHour:   req.CloseHour,
		BannerUrl:   &req.BannerUrl,
		Address:     &req.Address,
		Description: req.Description,
		Status:      entity.StoreStatusOpen,
	}

	err = s.storeRepo.Create(&store)
	if err != nil {
		return errors.New(BASE_MESSAGE)
	}
	
	return nil
}
