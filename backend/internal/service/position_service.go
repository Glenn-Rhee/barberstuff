package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/repository"
	"errors"
	"runtime"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type PositionService interface {
	CreatePosition(req dto.CreatePositionReq) error
}

type positionService struct {
	positionRepo repository.PositionRepository
}

func NewPositionService(pr repository.PositionRepository) PositionService {
	return &positionService{positionRepo: pr}
}

func (s *positionService) CreatePosition(req dto.CreatePositionReq) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat booking"
	_, filePath, _, _ := runtime.Caller(0)

	newPosition := entity.Position{
		ID:          uuid.New(),
		Name:        req.Name,
		BasicSalary: decimal.NewFromFloat(req.BasicSallary),
	}

	err := s.positionRepo.Create(&newPosition)

	if err != nil {
		if helper.IsUniqueViolation(err) {
			return errors.New("Jabatan ini telah terdaftar.")
		}

		helper.Logger("crete new position", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
