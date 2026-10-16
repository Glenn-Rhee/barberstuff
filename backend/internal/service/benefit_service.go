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
	PatchBenefit(ctx context.Context, req dto.PatchBenefitReq, id string) error
	DeleteBenefit(ctx context.Context, id string) error
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
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data benefit."
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

func (s *benefitService) PatchBenefit(ctx context.Context, req dto.PatchBenefitReq, id string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengupdate data benefit"
	_, filePath, _, _ := runtime.Caller(0)

	idBenefit, err := uuid.Parse(id)
	if err != nil {
		return errors.New("Id benefit tidak valid.")
	}

	if helper.IsAllFieldsNil(req) {
		return errors.New("Ubah minimal jadi 1 data")
	}

	updates := make(map[string]interface{})
	if req.Title != nil {
		updates["title"] = strings.TrimSpace(*req.Title)
	}

	if req.Description != nil {
		updates["description"] = strings.TrimSpace(*req.Description)
	}

	if req.Status != nil {
		updates["status"] = req.Status
	}

	var (
		errImage           = errors.New("Gagal memperbarui gambar.")
		errBenefitNotFound = errors.New("Benefit tidak ditemukan.")
	)

	err = s.db.Transaction(func(tx *gorm.DB) error {
		if req.ImageUrl != nil {
			permanentKey := lib.PermanentKey(*req.ImageUrl)
			updates["image_url"] = permanentKey
		}

		rowsAffected, err := s.benefitRepo.Updates(tx, updates, idBenefit)
		if err != nil {
			return err
		}

		if rowsAffected == 0 {
			return errBenefitNotFound
		}

		if req.ImageUrl != nil {
			_, err = lib.MoveObjectToPermanent(ctx, *req.ImageUrl)
			if err != nil {
				return errImage
			}

			benefit, err := s.benefitRepo.FindOne("id = ?", idBenefit)
			if err != nil {
				if errors.Is(err, gorm.ErrRecordNotFound) {
					return errBenefitNotFound
				}

				return err
			}

			if benefit.ImageUrl != nil && strings.Split(*benefit.ImageUrl, "/")[0] == "uploads" {
				err = lib.DeleteObject(ctx, *benefit.ImageUrl)
				if err != nil {
					return errImage
				}
			}
		}

		return nil
	})

	if err != nil {
		if errors.Is(err, errBenefitNotFound) || errors.Is(err, errImage) {
			return err
		}

		helper.Logger("update benefit", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *benefitService) DeleteBenefit(ctx context.Context, id string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat menghapus data benefit"
	_, filePath, _, _ := runtime.Caller(0)

	idBenefit, err := uuid.Parse(id)
	if err != nil {
		return errors.New("Id benefit tidak valid")
	}

	var (
		errBenefitNotFound = errors.New("Benefit not found")
		errFailedDelete    = errors.New("Failed delete image")
	)
	err = s.db.Transaction(func(tx *gorm.DB) error {
		benefit, rowsAffected, err := s.benefitRepo.Delete(tx, idBenefit)
		if err != nil {
			return err
		}

		if rowsAffected == 0 {
			return errBenefitNotFound
		}

		if benefit.ImageUrl != nil {
			err = lib.DeleteObject(ctx, *benefit.ImageUrl)
			if err != nil {
				return errFailedDelete
			}
		}

		return nil
	})

	if err != nil {
		if errors.Is(err, errBenefitNotFound) || errors.Is(err, errFailedDelete) {
			return errors.New("Benefit tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("delete benefit", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
