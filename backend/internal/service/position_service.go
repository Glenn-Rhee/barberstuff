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
	"gorm.io/gorm"
)

type PositionService interface {
	CreatePosition(req dto.CreatePositionReq) error
	GetPositions(req dto.GetPositionReq) ([]dto.GetPositionRes, error)
}

type positionService struct {
	positionRepo repository.PositionRepository
}

func NewPositionService(pr repository.PositionRepository) PositionService {
	return &positionService{positionRepo: pr}
}

func (s *positionService) CreatePosition(req dto.CreatePositionReq) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat jabatan baru."
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

func (s *positionService) GetPositions(req dto.GetPositionReq) ([]dto.GetPositionRes, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data jabatan."
	_, filePath, _, _ := runtime.Caller(0)

	var scopes []func(*gorm.DB) *gorm.DB
	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Where("deleted_at IS NULL")
	})

	if req.Query != nil {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			q := "%" + *req.Query + "%"
			return d.Where("name ILIKE ?", q)
		})
	}

	positins, err := s.positionRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("find all positions", filePath, err)
		return []dto.GetPositionRes{}, errors.New(BASE_MESSAGE)
	}

	dataPositions := make([]dto.GetPositionRes, 0, len(positins))
	for _, v := range positins {
		dataPositions = append(dataPositions, dto.GetPositionRes{
			ID:           v.ID,
			Name:         v.Name,
			BasicSallary: v.BasicSalary,
			CreatedAt:    v.CreatedAt,
		})
	}

	return dataPositions, nil
}
