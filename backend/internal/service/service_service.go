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

type ServiceService interface {
	GetServices(query dto.QueryParamsService, claims *lib.CustomClaims) ([]dto.GetServiceResponse, dto.ResponsePagination, error)
}

type serviceService struct {
	serviceRepo repository.ServiceRepository
	storeRepo   repository.StoreRepository
}

func NewServiceService(sr repository.ServiceRepository, str repository.StoreRepository) ServiceService {
	return &serviceService{serviceRepo: sr, storeRepo: str}
}

func (s *serviceService) GetServices(query dto.QueryParamsService, claims *lib.CustomClaims) ([]dto.GetServiceResponse, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data!"
	_, filePath, _, _ := runtime.Caller(0)

	idStore, err := uuid.Parse(query.IdStore)
	if err != nil {
		helper.Logger("parse id store", filePath, err)
		return []dto.GetServiceResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	_, err = s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return []dto.GetServiceResponse{}, dto.ResponsePagination{}, errors.New("Data toko tidak ditemukan atau telah dihapus!")
		}
		helper.Logger("find one store", filePath, err)
		return []dto.GetServiceResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	var scopes []func(*gorm.DB) *gorm.DB
	if claims.Role == entity.RoleCustomer {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("status = ?", entity.ProductStatusActive)
		})
	}

	if query.ServiceName != nil {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			q := "%"
			q += *query.ServiceName
			q += "%"
			return d.Where("name ILIKE ?", q)
		})
	}

	var page = 1
	var limit = 20
	var sortBy = dto.ServiceByName
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

	totalData, err := s.serviceRepo.Count(scopes...)
	if err != nil {
		helper.Logger("counted service data", filePath, err)
		return []dto.GetServiceResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Order(sortBy + " " + dto.SortService(orderBy)).
			Offset((page - 1) * limit).
			Limit(limit)
	})

	paginationData := helper.GetPaginationData(page, limit, int(totalData))

	services, err := s.serviceRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("find all data services", filePath, err)
		return []dto.GetServiceResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	dataServices := make([]dto.GetServiceResponse, 0, len(services))

	for _, v := range services {
		dataServices = append(dataServices, dto.GetServiceResponse{
			Id: v.ID,
			Name: v.Name,
			Price: v.Price,
			Description: v.Description,
			Status: v.Status,
			IdStore: v.IdStore,
			Type: v.Type,
			CreatedAt: v.CreatedAt,
		})
	}

	return dataServices, paginationData, nil
}
