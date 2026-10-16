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
	"gorm.io/gorm/clause"
)

type BenefitService interface {
	CrateBenefit(ctx context.Context, req dto.CreateBenefitReq) error
	GetBenefits(req dto.GetBenefitReq, claims *lib.CustomClaims) ([]dto.GetBenefitRes, dto.ResponsePagination, error)
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

func (s *benefitService) GetBenefits(req dto.GetBenefitReq, claims *lib.CustomClaims) ([]dto.GetBenefitRes, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat benefit baru, mohon upload ulang."
	_, filePath, _, _ := runtime.Caller(0)

	var scopes []func(*gorm.DB) *gorm.DB
	if req.Query != nil {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			q := "%" + *req.Query + "%"
			return d.Where("title ILIKE ? OR description ILIKE ?", q, q)
		})
	}

	var page = 1
	var limit = 20
	var sortBy = dto.SortBenefitStatus
	var orderBy = dto.OrderDesc

	if req.Page != nil {
		page = *req.Page
	}

	if req.Limit != nil {
		limit = *req.Limit
	}

	if req.SortBy != nil {
		sortBy = *req.SortBy
	}

	if req.OrderBy != nil {
		orderBy = *req.OrderBy
	}

	if claims.Role != entity.RoleCustomer && req.Status != nil {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("status = ?", req.Status)
		})
	}

	if claims.Role == entity.RoleCustomer {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("status = ?", entity.BenefitStatusVisible)
		})
	}

	totalData, err := s.benefitRepo.Count(scopes...)
	if err != nil {
		helper.Logger("count benefit", filePath, err)
		return []dto.GetBenefitRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Clauses(clause.OrderBy{
			Columns: []clause.OrderByColumn{
				{Column: clause.Column{Name: string(sortBy)}, Desc: orderBy == dto.OrderDesc},
				{Column: clause.Column{Name: "id"}, Desc: orderBy == dto.OrderDesc},
			},
		}).Offset((page - 1) * limit).Limit(limit)
	})

	paginationData := helper.GetPaginationData(page, limit, int(totalData))

	benefits, err := s.benefitRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("find all benefits", filePath, err)
		return []dto.GetBenefitRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	dataBenefits := make([]dto.GetBenefitRes, 0, len(benefits))
	for _, v := range benefits {

		var status *entity.BenefitStatusEnum

		if claims.Role != entity.RoleCustomer {
			status = &v.Status
		}

		var imgUrl *string
		if v.ImageUrl != nil {
			pressignedUrl, err := lib.GeneratePressignedGetURL(*v.ImageUrl)
			if err != nil {
				helper.Logger("failed generate url", filePath, err)
			}

			imgUrl = &pressignedUrl
		}

		dataBenefits = append(dataBenefits, dto.GetBenefitRes{
			ID:          v.ID,
			Title:       v.Title,
			Description: v.Description,
			ImageUrl:    imgUrl,
			CreatedAt:   v.CreatedAt,
			Status:      status,
		})
	}

	return dataBenefits, paginationData, nil
}
