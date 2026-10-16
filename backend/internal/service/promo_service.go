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
	DeletePromo(id string) error
	ClaimPromo(id string, claimUser *lib.CustomClaims) error
	GetClaimPromo(req dto.GetPromoClaimReq, claimUser *lib.CustomClaims) ([]dto.GetPromoClaimRes, dto.ResponsePagination, error)
}

type promoService struct {
	promoRepo    repository.PromoRepository
	customerRepo repository.CustomerRepository
}

func NewPromoService(pr repository.PromoRepository, cr repository.CustomerRepository) PromoService {
	return &promoService{promoRepo: pr, customerRepo: cr}
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
		StartAt:               req.StartAt,
		ExpiredAt:             req.ExpiredAt,
		MinMemberPoints:       req.MinMemberPoints,
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

	// status claim per promo (khusus customer)
	type claimStatus struct {
		hasUnused    bool  // ada claim yang belum digunakan
		totalClaimed int64 // total claim (sudah dipakai + belum)
	}
	claimMap := make(map[uuid.UUID]*claimStatus)

	if claims.Role == entity.RoleCustomer && len(promoes) > 0 {
		promoIDs := make([]uuid.UUID, 0, len(promoes))
		for _, p := range promoes {
			promoIDs = append(promoIDs, p.ID)
		}

		claimeds, err := s.promoRepo.FindAllWithClaimed(func(d *gorm.DB) *gorm.DB {
			return d.
				Where("id_user = ?", claims.UserId).
				Where("id_promo IN ?", promoIDs)
		})
		if err != nil {
			helper.Logger("find all claimed promo", filePath, err)
			return []dto.GetPromoRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
		}

		for _, c := range claimeds {
			st, ok := claimMap[c.IDPromo]
			if !ok {
				st = &claimStatus{}
				claimMap[c.IDPromo] = st
			}
			st.totalClaimed++
			if !c.IsUsed {
				st.hasUnused = true
			}
		}
	}

	dataPromoes := make([]dto.GetPromoRes, 0, len(promoes))

	for _, v := range promoes {
		pressignedURL, err := lib.GeneratePressignedGetURL(v.ImagePromo)
		if err != nil {
			helper.Logger("Generate presigned url", filePath, err)
		}

		var usageLimit *int64
		var isClaim *bool

		if claims.Role != entity.RoleCustomer {
			usageLimit = v.UsageLimitPerCustomer
		} else if st, ok := claimMap[v.ID]; ok {
			switch {
			case st.hasUnused:
				claimed := true
				isClaim = &claimed
			case v.UsageLimitPerCustomer != nil && st.totalClaimed >= *v.UsageLimitPerCustomer:
				claimed := true
				isClaim = &claimed
			default:
				claimed := false
				isClaim = &claimed
			}
		}

		dataPromoes = append(dataPromoes, dto.GetPromoRes{
			Status:             v.Status,
			UsageLimitCustomer: usageLimit,
			IsClaim:            isClaim,
			DataPromo: dto.DataPromo{
				ID:              v.ID,
				Title:           v.Title,
				Description:     v.Description,
				DiscountType:    v.DiscountType,
				DiscountValue:   v.DiscountValue,
				MinMemberPoints: v.MinMemberPoints,
				StartAt:         v.StartAt,
				ExpiredAt:       v.ExpiredAt,
				ImageUrl:        pressignedURL,
			},
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
		updates["usage_limit_per_customer"] = req.UsageLimitCustomer
	}

	if req.MinMemberPoints != nil {
		updates["min_member_points"] = req.MinMemberPoints
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

func (s *promoService) DeletePromo(id string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat menghapus promo."
	_, filePath, _, _ := runtime.Caller(0)

	idPromo, err := uuid.Parse(id)
	if err != nil {
		return errors.New("Id promo tidak valid")
	}

	rowsAffected, err := s.promoRepo.SoftDelete(idPromo)
	if err != nil {
		helper.Logger("delete promo", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if rowsAffected == 0 {
		return errors.New("Promo tidak ditemukan atau telah dihapus.")
	}

	return nil
}

// businessError menandai error yang pesannya aman ditampilkan ke user.
type businessError struct{ msg string }

func (e *businessError) Error() string { return e.msg }

func newBusinessError(msg string) error {
	return &businessError{msg: msg}
}

func (s *promoService) ClaimPromo(id string, claimUser *lib.CustomClaims) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat claim promo."
	_, filePath, _, _ := runtime.Caller(0)

	idPromo, err := uuid.Parse(id)
	if err != nil {
		return errors.New("Id promo tidak valid.")
	}

	idUser, err := uuid.Parse(claimUser.UserId)
	if err != nil {
		return errors.New("Data tidak valid, mohon login ulang.")
	}

	err = s.promoRepo.Transaction(func(tx repository.PromoRepository) error {
		// Kunci baris promo supaya request bersamaan untuk promo ini antre satu per satu.
		promo, err := tx.FindOneForUpdate("id = ? AND status = ?", idPromo, entity.PromoStatusVisible)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return newBusinessError("Promo tidak ditemukan atau tidak dapat di claim.")
			}
			return err
		}

		// Cek masa berlaku.
		now := time.Now()
		if promo.StartAt != nil && promo.StartAt.After(now) {
			return newBusinessError("Promo belum berlaku.")
		}
		if promo.ExpiredAt != nil && !promo.ExpiredAt.After(now) {
			return newBusinessError("Promo sudah berakhir.")
		}

		// Claim promo yang sama dan belum dipakai harus dipakai dulu.
		unusedClaims, err := tx.CountClaimed(func(d *gorm.DB) *gorm.DB {
			return d.Where("id_promo = ? AND id_user = ? AND is_used = ?", idPromo, idUser, false)
		})
		if err != nil {
			return err
		}
		if unusedClaims > 0 {
			return newBusinessError("Anda masih memiliki promo ini yang belum digunakan.")
		}

		// Cek batas total claim per customer (nil = tanpa batas).
		if promo.UsageLimitPerCustomer != nil {
			totalClaims, err := tx.CountClaimed(func(d *gorm.DB) *gorm.DB {
				return d.Where("id_promo = ? AND id_user = ?", idPromo, idUser)
			})
			if err != nil {
				return err
			}
			if totalClaims >= *promo.UsageLimitPerCustomer {
				return newBusinessError("Anda sudah mencapai batas maximum claim promo ini.")
			}
		}

		// Cek apakah ada syartt minimum member point
		dataCustomer, err := s.customerRepo.FindOne("id = ?", idUser)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return newBusinessError("Akun tidak ditemukan. Mohon daftar ulang.")
			}

			return err
		}

		if promo.MinMemberPoints != nil && dataCustomer.MemberPoints < int(*promo.MinMemberPoints) {
			return newBusinessError("Poin member anda tidak cukup.")
		}

		return tx.CreateClaimed(&entity.PromoClaimed{
			ID:      uuid.New(),
			IDPromo: idPromo,
			IDUser:  idUser,
			IsUsed:  false,
		})
	})

	if err != nil {
		var bizErr *businessError
		if errors.As(err, &bizErr) {
			return bizErr
		}

		helper.Logger("claim promo", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *promoService) GetClaimPromo(req dto.GetPromoClaimReq, claimUser *lib.CustomClaims) ([]dto.GetPromoClaimRes, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat claim promo."
	_, filePath, _, _ := runtime.Caller(0)

	idCustomer, err := uuid.Parse(claimUser.UserId)
	if err != nil {
		return []dto.GetPromoClaimRes{}, dto.ResponsePagination{}, errors.New("Akun tidak valid, mohon login ulang.")
	}

	var scopes []func(*gorm.DB) *gorm.DB
	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.
			Preload("Promo").
			Joins("JOIN promo ON promo.id = promo_claimed.id_promo").
			Where("promo.deleted_at IS NULL").
			Where("promo_claimed.id_user = ? AND promo_claimed.is_used = ?", idCustomer, false)

	})
	var page = 1
	var limit = 20
	var sortBy = dto.SortPromoByCreatedAt
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

	if req.DiscountType != nil {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.
				Where("promo.discount_type = ?", req.DiscountType)
		})
	}

	var sort string

	switch sortBy {
	case dto.SortPromoByTitle:
		sort = "promo.title"
	case dto.SortPromoByValue:
		sort = "promo.discount_value"
	default:
		sort = "promo_claimed.created_at"
	}

	totalData, err := s.promoRepo.CountClaimed(scopes...)
	if err != nil {
		helper.Logger("count promo", filePath, err)
		return []dto.GetPromoClaimRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}
	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Clauses(clause.OrderBy{
			Columns: []clause.OrderByColumn{
				{Column: clause.Column{Name: sort}, Desc: orderBy == dto.OrderDesc},
				{Column: clause.Column{Name: "promo_claimed.id"}, Desc: orderBy == dto.OrderDesc},
			},
		}).Offset((page - 1) * limit).Limit(limit)
	})

	paginationData := helper.GetPaginationData(page, limit, int(totalData))

	promoClaims, err := s.promoRepo.FindAllWithClaimed(scopes...)
	if err != nil {
		helper.Logger("find all promo", filePath, err)
		return []dto.GetPromoClaimRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	dataPromoClaims := make([]dto.GetPromoClaimRes, 0, len(promoClaims))

	for _, v := range promoClaims {
		pressignedURL, err := lib.GeneratePressignedGetURL(v.Promo.ImagePromo)
		if err != nil {
			helper.Logger("generate presigned url", filePath, err)
		}

		dataPromoClaims = append(dataPromoClaims, dto.GetPromoClaimRes{
			Id:        v.ID,
			ClaimedAt: v.CreatedAt,
			Promo: dto.DataPromo{
				ID:              v.Promo.ID,
				Title:           v.Promo.Title,
				Description:     v.Promo.Description,
				DiscountType:    v.Promo.DiscountType,
				DiscountValue:   v.Promo.DiscountValue,
				MinMemberPoints: v.Promo.MinMemberPoints,
				StartAt:         v.Promo.StartAt,
				ExpiredAt:       v.Promo.ExpiredAt,
				ImageUrl:        pressignedURL,
			},
		})
	}

	return dataPromoClaims, paginationData, nil
}
