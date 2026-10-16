package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"context"
	"errors"
	"runtime"
	"strings"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type BenefitService interface {
	CrateBenefit(ctx context.Context, req dto.CreateBenefitReq) error
}

type benefitService struct {
	benefitRepo repository.BenefitRepository
	db          *gorm.DB
}

func NewBenefitService(br repository.BenefitRepository, d *gorm.DB) BenefitService {
	return &benefitService{benefitRepo: br, db: d}
}

func (s *benefitService) CrateBenefit(ctx context.Context, req dto.CreateBenefitReq) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat benefit baru, mohon upload ulang."
	_, filePath, _, _ := runtime.Caller(0)

	tempKey := strings.TrimSpace(req.ImageUrl)
	permanentKey := lib.PermanentKey(tempKey)

	err := s.db.Transaction(func(tx *gorm.DB) error {
		newBenefit := entity.Benefit{
			ID:          uuid.New(),
			Title:       strings.TrimSpace(req.Title),
			Description: strings.TrimSpace(req.Description),
			ImageUrl:    &permanentKey,
			Status:      req.Status,
		}

		err := s.benefitRepo.Create(tx, &newBenefit)
		if err != nil {
			return errors.New(BASE_MESSAGE)
		}

		_, err = lib.MoveObjectToPermanent(ctx, strings.TrimSpace(req.ImageUrl))
		if err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		helper.Logger("create benefit", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
