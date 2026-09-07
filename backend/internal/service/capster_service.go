package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"errors"
	"runtime"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type CapsterService interface {
	Create(req dto.CreateCapsterRequest) error
	GetCapsters(query dto.QueryParamsCapsters, claims *lib.CustomClaims) ([]dto.CapsterDataResponse, dto.ResponsePagination, error)
}

type capsterService struct {
	capsterRepo repository.CapsterRepository
	storeRepo   repository.StoreRepository
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
		ID:       uuid.New(),
		Name:     req.Name,
		Status:   entity.CapsterStatusActive,
		ImageUrl: &req.ImageUrl,
		IDStore:  idStore,
	}

	err = s.capsterRepo.Create(&capster)
	if err != nil {
		helper.Logger("create capster", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *capsterService) GetCapsters(query dto.QueryParamsCapsters, claims *lib.CustomClaims) ([]dto.CapsterDataResponse, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data capster!"
	_, filePath, _, _ := runtime.Caller(0)

	idStore, err := uuid.Parse(query.IdStore)
	if err != nil {
		helper.Logger("parse id store", filePath, err)
		return []dto.CapsterDataResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	_, err = s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return []dto.CapsterDataResponse{}, dto.ResponsePagination{}, errors.New("Data toko tidak ditemukan atau telah dihapus!")
		}
		helper.Logger("find one store", filePath, err)
		return []dto.CapsterDataResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	var scopes []func(*gorm.DB) *gorm.DB
	if claims.Role == entity.RoleCustomer {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("status = ?", entity.CapsterStatusActive)
		})
	}

	if query.CapsterName != nil {
		q := "%"
		q += *query.CapsterName
		q += "%"
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("name ILIKE ?", q)
		})
	}

	var page = 1
	var limit = 20
	var sortBy = dto.CapsterByName
	var orderBy = dto.OrderAsc

	if query.Page != nil {
		page = *query.Page
	}

	if query.Limit != nil {
		limit = *query.Limit
	}

	if query.SortBy != nil {
		sortBy = *query.SortBy
	}

	if query.OrderBy != nil {
		orderBy = *query.OrderBy
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Where("deleted_at IS NULL").Where("id_store = ?", idStore)
	})

	totalData, err := s.capsterRepo.Count(scopes...)
	if err != nil {
		helper.Logger("counted capster data", filePath, err)
		return []dto.CapsterDataResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Order(sortBy + " " + dto.SortCapster(orderBy)).
			Offset((page - 1) * limit).
			Limit(limit)
	})

	paginationData := helper.GetPaginationData(page, limit, int(totalData))

	capsters, err := s.capsterRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("Find all data capster", filePath, err)
		return []dto.CapsterDataResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	dataCapsters := make([]dto.CapsterDataResponse, 0, len(capsters))

	for _, v := range capsters {
		var totalRating = 0
		var avgRating float64 = 5.0
		for _, r := range v.Ratings {
			totalRating += int(r.Score)
		}

		if len(v.Ratings) > 0 {
			avgRating = float64(totalRating) / float64(len(v.Ratings))
		}

		dataCapsters = append(dataCapsters, dto.CapsterDataResponse{
			Id:        v.ID,
			Name:      v.Name,
			Status:    v.Status,
			ImageUrl:  *v.ImageUrl,
			AvgRating: avgRating,
			IdStore:   v.IDStore,
			CreatedAt: v.CreatedAt,
		})
	}

	return dataCapsters, paginationData, nil
}
