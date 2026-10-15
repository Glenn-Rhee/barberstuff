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
	"github.com/shopspring/decimal"
)

type PromoService interface {
	CreatePromo(ctx context.Context, req dto.CreatePromoReq) error
}

type promoService struct {
	promoRepo repository.PromoRepository
}

func NewPromoService(pr repository.PromoRepository) PromoService {
	return &promoService{promoRepo: pr}
}

func (s *promoService) CreatePromo(ctx context.Context, req dto.CreatePromoReq) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat promo."
	_, filePath, _, _ := runtime.Caller(0)

	if req.DiscountType == entity.DiscountTypePercentage && req.DiscountValue > 100 {
		return errors.New("Maximum persentase diskon adalah 100%")
	}

	var description *string
	if req.Description != nil {
		trimmed := strings.TrimSpace(*req.Description)
		description = &trimmed
	}

	permanentKey, err := lib.MoveObjectToPermanent(ctx, req.ImageUrl)
	if err != nil {
		return err
	}

	newPromo := entity.Promo{
		ID:                    uuid.New(),
		Title:                 strings.TrimSpace(req.Title),
		Status:                req.Status,
		Description:           description,
		DiscountType:          req.DiscountType,
		DiscountValue:         decimal.NewFromFloat(req.DiscountValue),
		UsageLimitPerCustomer: req.UsageLimitCustomer,
		StartAt:               &req.StartAt,
		ExpiredAt:             &req.ExpiredAt,
		ImagePromo:            permanentKey,
	}

	err = s.promoRepo.Create(&newPromo)
	if err != nil {
		helper.Logger("create promo", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
