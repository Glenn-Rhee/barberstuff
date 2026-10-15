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
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type PromoService interface {
	CreatePromo(ctx context.Context, req dto.CreatePromoReq) error
	GetPromo(req dto.GetPromoReq, claims *lib.CustomClaims) ([]dto.GetPromoRes, dto.ResponsePagination, error)
	PatchPromo(ctx context.Context, req dto.PatchPromoReq, id string) error
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

func (s *promoService) GetPromo(req dto.GetPromoReq, claims *lib.CustomClaims) ([]dto.GetPromoRes, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data promo."
	_, filePath, _, _ := runtime.Caller(0)

	var scopes []func(*gorm.DB) *gorm.DB
	if req.Query != nil {
		q := "%" + *req.Query + "%"
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("promo.title ILIKE ? OR promo.description ILIKE ?", q, q)
		})
	}

	var page = 1
	var limit = 20
	var sortBy *string
	var orderBy = dto.OrderAsc

	if req.Page != nil {
		page = *req.Page
	}

	if req.Limit != nil {
		limit = *req.Limit
	}

	if req.SortBy != nil {
		sortBy = (*string)(req.SortBy)
	}

	if req.OrderBy != nil {
		orderBy = *req.OrderBy
	}

	useMostClaimed := req.SortBy == nil

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		d = d.Where("promo.deleted_at IS NULL")
		if claims.Role != entity.RoleCustomer && req.Status != nil {
			d = d.Where("promo.status = ?", req.Status)
		}

		if claims.Role == entity.RoleCustomer {
			now := time.Now()
			d = d.
				Where("promo.status = ?", entity.PromoStatusVisible).
				Where("(promo.start_at IS NULL OR promo.start_at <= ?)", now).
				Where("(promo.expired_at IS NULL OR promo.expired_at > ?)", now)
		}

		if req.DiscountType != nil {
			d = d.Where("promo.discount_type = ?", req.DiscountType)
		}

		return d
	})

	totalData, err := s.promoRepo.Count(scopes...)
	if err != nil {
		helper.Logger("count total promo", filePath, err)
		return []dto.GetPromoRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	if useMostClaimed {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			claimCounts := d.Session(&gorm.Session{NewDB: true}).
				Table("promo_claimed").
				Select("id_promo, COUNT(*) AS total_claimed").
				Group("id_promo")

			return d.
				Joins("LEFT JOIN (?) AS pc ON pc.id_promo = promo.id", claimCounts).
				Order("COALESCE(pc.total_claimed, 0) DESC").
				Order("promo.created_at DESC").
				Offset((page - 1) * limit).
				Limit(limit)
		})
	} else {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Clauses(clause.OrderBy{
				Columns: []clause.OrderByColumn{
					{
						Column: clause.Column{Name: *sortBy},
						Desc:   orderBy == dto.OrderDesc,
					},
				},
			}).Offset((page - 1) * limit).Limit(limit)
		})
	}

	paginationData := helper.GetPaginationData(page, limit, int(totalData))

	promoes, err := s.promoRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("find all promo", filePath, err)
		return []dto.GetPromoRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	dataPromoes := make([]dto.GetPromoRes, 0, len(promoes))

	for _, v := range promoes {
		pressignedURL, err := lib.GeneratePressignedGetURL(v.ImagePromo)
		if err != nil {
			helper.Logger("Generate presigned url", filePath, err)
		}

		var usageLimit *int64
		if claims.Role != entity.RoleCustomer {
			usageLimit = v.UsageLimitPerCustomer
		}

		dataPromoes = append(dataPromoes, dto.GetPromoRes{
			ID:                 v.ID,
			Title:              v.Title,
			Status:             v.Status,
			Description:        v.Description,
			DiscountType:       v.DiscountType,
			DiscountValue:      v.DiscountValue,
			UsageLimitCustomer: usageLimit,
			StartAt:            *v.StartAt,
			ExpiredAt:          *v.ExpiredAt,
			ImageUrl:           pressignedURL,
		})
	}

	return dataPromoes, paginationData, nil
}

func (s *promoService) PatchPromo(ctx context.Context, req dto.PatchPromoReq, id string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengubah promo."
	_, filePath, _, _ := runtime.Caller(0)

	idPromo, err := uuid.Parse(id)
	if err != nil {
		return errors.New("Id promo tidak valid.")
	}

	if helper.IsAllFieldsNil(req) {
		return errors.New("Ubah setidaknya 1 data.")
	}

	updates := make(map[string]interface{})

	if (req.DiscountType != nil && req.DiscountValue == nil) ||
		(req.DiscountType == nil && req.DiscountValue != nil) {
		return errors.New("Tipe diskon dan jumlah diskon wajib diisi.")
	}

	if req.Title != nil {
		updates["title"] = strings.TrimSpace(*req.Title)
	}

	if req.Status != nil {
		updates["status"] = req.Status
	}

	if req.Description != nil {
		updates["description"] = req.Description
	}

	if req.DiscountType != nil && req.DiscountValue != nil {
		if *req.DiscountType == entity.DiscountTypePercentage && *req.DiscountValue > 100 {
			return errors.New("Maximum persentase diskon adalah 100%")
		}

		updates["discount_type"] = req.DiscountType
		updates["discount_value"] = req.DiscountValue
	}

	if req.UsageLimitCustomer != nil {
		updates["usage_limit_customer"] = req.UsageLimitCustomer
	}

	if req.StartAt != nil {
		updates["start_at"] = req.StartAt
	}

	if req.ExpiredAt != nil {
		updates["expired_at"] = req.ExpiredAt
	}

	if req.ImageUrl != nil {
		dataPromo, err := s.promoRepo.FindOne("id = ?", idPromo)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return errors.New("Promo tidak ditemukan atau telah dihapus.")
			}

			helper.Logger("find one promo", filePath, err)
			return errors.New(BASE_MESSAGE)
		}

		if strings.Split(dataPromo.ImagePromo, "/")[0] == "uploads" {
			err := lib.DeleteObject(ctx, dataPromo.ImagePromo)
			if err != nil {
				helper.Logger("delete image employee", filePath, err)
				return errors.New(BASE_MESSAGE)
			}
		}

		permanentKey, err := lib.MoveObjectToPermanent(ctx, *req.ImageUrl)
		if err != nil {
			return err
		}

		updates["image_promo"] = permanentKey
	}

	rowsAffected, err := s.promoRepo.Updates(updates, idPromo)
	if err != nil {
		helper.Logger("update promo", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if rowsAffected == 0 {
		return errors.New("Promo tidak ditemukan atau telah dihapus.")
	}

	return nil
}
