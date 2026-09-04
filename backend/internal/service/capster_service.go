package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/repository"
	"errors"
	"runtime"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type CapsterService interface {
	Create(req dto.CreateCapsterRequest) error
}

type capsterService struct {
	capsterRepo repository.CapsterRepository
	storeRepo repository.StoreRepository
}

func NewCapsterService(cr repository.CapsterRepository, sr repository.StoreRepository) CapsterService {
	return &capsterService{capsterRepo: cr, storeRepo: sr}
}

func (s *capsterService) Create(req dto.CreateCapsterRequest) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat data capster!"
	_, filePath, _, _ := runtime.Caller(0)

	_, err := s.capsterRepo.FindOne("name = ?", req.Name)
	if err == nil {
		return errors.New("Nama capster ini sudah ada!")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("find one capster", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return errors.New("Format id toko tidak valid!")
	}
	_, err = s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko untuk membuat capster ini tidak ditemukan!")
		}

		helper.Logger("find one store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	capster := entity.Capster{
		ID: uuid.New(),
		Name: req.Name,
		Status: entity.CapsterStatusActive,
		ImageUrl: &req.ImageUrl,
		IDStore: idStore,
	}

	err = s.capsterRepo.Create(&capster)
	if err != nil {
		helper.Logger("create capster", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
