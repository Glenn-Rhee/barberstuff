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
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type ServiceService interface {
	GetServices(query dto.QueryParamsService, claims *lib.CustomClaims) ([]dto.GetServiceResponse, dto.ResponsePagination, error)
	CreateService(req dto.CreateServiceRequest) error
	UpdateService(req dto.UpdateServiceRequest, id string) error
	DeleteService(id string) error
}

type serviceService struct {
	serviceRepo repository.ServiceRepository
	storeRepo   repository.StoreRepository
	bookingRepo repository.BookingRepository
}

func NewServiceService(sr repository.ServiceRepository, str repository.StoreRepository, br repository.BookingRepository) ServiceService {
	return &serviceService{serviceRepo: sr, storeRepo: str, bookingRepo: br}
}

func (s *serviceService) GetServices(query dto.QueryParamsService, claims *lib.CustomClaims) ([]dto.GetServiceResponse, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data!"
	_, filePath, _, _ := runtime.Caller(0)

	// id_store opsional: nil = semua toko
	var idStore *uuid.UUID
	if query.IdStore != nil && *query.IdStore != "" {
		parsed, err := uuid.Parse(*query.IdStore)
		if err != nil {
			return []dto.GetServiceResponse{}, dto.ResponsePagination{}, errors.New("id toko tidak valid.")
		}

		_, err = s.storeRepo.FindOne("id = ?", parsed)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return []dto.GetServiceResponse{}, dto.ResponsePagination{}, errors.New("Data toko tidak ditemukan atau telah dihapus!")
			}
			helper.Logger("find one store", filePath, err)
			return []dto.GetServiceResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
		}
		idStore = &parsed
	}

	var scopes []func(*gorm.DB) *gorm.DB
	if claims.Role == entity.RoleCustomer {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("status = ?", entity.ProductStatusActive)
		})
	}

	if query.ServiceName != nil {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("name ILIKE ?", "%"+*query.ServiceName+"%")
		})
	}

	var page = 1
	var limit = 20
	var sortBy = dto.ServiceByName
	var orderBy = dto.OrderAsc

	// default: paling laku, kecuali client memilih sort_by sendiri
	useBestSeller := query.SortBy == nil

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
		d = d.Where("deleted_at IS NULL")
		if idStore != nil {
			d = d.Where("id_store = ?", *idStore)
		}

		if query.Type != nil {
			d = d.Where("type = ?", query.Type)
		}
		return d
	})

	totalData, err := s.serviceRepo.Count(scopes...)
	if err != nil {
		helper.Logger("counted service data", filePath, err)
		return []dto.GetServiceResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	if useBestSeller {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.
				Joins(`LEFT JOIN (
					SELECT bi.id_service, COUNT(*) AS total_sold
					FROM booking_item bi
					JOIN booking b ON b.id = bi.id_booking
					WHERE b.status_booking = ?
					GROUP BY bi.id_service
				) sold ON sold.id_service = service.id`, entity.BookingStatusCompleted).
				Order("COALESCE(sold.total_sold, 0) DESC").
				Order("service.name ASC").
				Offset((page - 1) * limit).
				Limit(limit)
		})
	} else {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Clauses(clause.OrderBy{
				Columns: []clause.OrderByColumn{
					{
						Column: clause.Column{Name: string(sortBy)},
						Desc:   dto.SortService(orderBy) == "desc",
					},
				},
			}).Offset((page - 1) * limit).Limit(limit)
		})
	}

	paginationData := helper.GetPaginationData(page, limit, int(totalData))

	services, err := s.serviceRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("find all data services", filePath, err)
		return []dto.GetServiceResponse{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	dataServices := make([]dto.GetServiceResponse, 0, len(services))
	for _, v := range services {
		dataServices = append(dataServices, dto.GetServiceResponse{
			Id:          v.ID,
			Name:        v.Name,
			Price:       v.Price,
			Description: v.Description,
			Status:      v.Status,
			IdStore:     v.IdStore,
			Type:        v.Type,
			CreatedAt:   v.CreatedAt,
		})
	}

	return dataServices, paginationData, nil
}

func (s *serviceService) CreateService(req dto.CreateServiceRequest) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat data!"
	_, filePath, _, _ := runtime.Caller(0)

	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return errors.New("Data toko tidak valid!")
	}

	_, err = s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("find one service", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	_, err = s.serviceRepo.FindOne("name = ? AND type = ?", req.Name, req.Type)
	if err == nil {
		return errors.New("Service atau paket ini sudah tersedia")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("find one service", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	newProduct := entity.Service{
		ID:          uuid.New(),
		Name:        req.Name,
		Price:       decimal.NewFromFloat(req.Price),
		Description: req.Description,
		Status:      entity.ProductStatusActive,
		IdStore:     idStore,
		Type:        req.Type,
	}

	err = s.serviceRepo.Create(&newProduct)
	if err != nil {
		helper.Logger("create data service", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *serviceService) UpdateService(req dto.UpdateServiceRequest, id string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengubah data!"
	_, filePath, _, _ := runtime.Caller(0)

	idService, err := uuid.Parse(id)
	if err != nil {
		return errors.New("Id service tidak valid!")
	}

	if helper.IsAllFieldsNil(req) {
		return errors.New("Update setidaknya 1 data.")
	}

	var updates = make(map[string]interface{})
	if req.Name != nil {
		updates["name"] = req.Name
	}

	if req.Price != nil {
		updates["price"] = decimal.NewFromFloat(*req.Price)
	}

	if req.Description != nil {
		updates["description"] = req.Description
	}

	if req.Status != nil {
		updates["status"] = req.Status
	}

	rowsAffected, err := s.serviceRepo.Updates(updates, idService)
	if err != nil {
		helper.Logger("update data service", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if rowsAffected == 0 {
		return errors.New("Data service tidak ditemukan atau telah dihapus!")
	}

	return nil
}

func (s *serviceService) DeleteService(id string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengubah data!"
	_, filePath, _, _ := runtime.Caller(0)

	idService, err := uuid.Parse(id)
	if err != nil {
		return errors.New("Id service tidak valid!")
	}

	rowsAffected, err := s.serviceRepo.SoftDelete(idService)
	if err != nil {
		helper.Logger("Soft delete service", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if rowsAffected == 0 {
		return errors.New("Data service tidak dapat ditemukan atau telah dihapu.")
	}

	return nil
}
