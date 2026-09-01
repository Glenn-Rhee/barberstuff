package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"errors"
	"fmt"
	"runtime"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type StoreService interface {
	CreateNewStore(req dto.NewStoreRequest) error
	GetStores(query dto.QueryParamsStores) ([]dto.StoreData, error)
	GetStore(claims lib.CustomClaims, idStore string) (dto.StoreResponse, error)
	UpdateStore(req dto.UpdateStoreRequest, storeId string) error
}

type storeService struct {
	storeRepo   repository.StoreRepository
	serviceRepo repository.ServiceRepository
	packageRepo repository.PackageRepository
	ratingRepo  repository.RatingRepository
	capsterRepo repository.CapsterRepository
}

func NewStoreService(
	storeRepo repository.StoreRepository,
	sr repository.ServiceRepository,
	pr repository.PackageRepository,
	rr repository.RatingRepository,
	cr repository.CapsterRepository,
) StoreService {
	return &storeService{
		storeRepo:   storeRepo,
		serviceRepo: sr,
		packageRepo: pr,
		ratingRepo:  rr,
		capsterRepo: cr,
	}
}

func (s *storeService) CreateNewStore(req dto.NewStoreRequest) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat data toko!"
	_, filePath, _, _ := runtime.Caller(0)

	_, err := s.storeRepo.FindOne("name = ?", req.Name)
	if err == nil {
		return errors.New("Store name sudah tersedia! Anda tidak dapat menambahkannya kembali")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find data store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	coordinate := fmt.Sprintf("%f,%f", req.Lat, req.Long)
	store := entity.Store{
		ID:          uuid.New(),
		Name:        req.Name,
		PhoneNumber: &req.PhoneNumber,
		Coordinate:  &coordinate,
		OpenHour:    req.OpenHour,
		CloseHour:   req.CloseHour,
		BannerUrl:   &req.BannerUrl,
		Address:     &req.Address,
		Description: req.Description,
		Status:      entity.StoreStatusOpen,
	}

	err = s.storeRepo.Create(&store)
	if err != nil {
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *storeService) GetStores(query dto.QueryParamsStores) ([]dto.StoreData, error) {
	var scopes []func(*gorm.DB) *gorm.DB
	if query.NameStore != nil {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("name = ?", query.NameStore)
		})
	}

	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data toko!"
	_, filePath, _, _ := runtime.Caller(0)

	stores, err := s.storeRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("Find all data", filePath, err)
		return []dto.StoreData{}, errors.New(BASE_MESSAGE)
	}

	return dto.ToStoreResponseList(stores), nil
}

func (s *storeService) GetStore(claims lib.CustomClaims, idStore string) (dto.StoreResponse, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data toko!"
	_, filePath, _, _ := runtime.Caller(0)

	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.StoreResponse{}, errors.New("Data toko cabang yang anda cari tidak ditemukan!")
		}

		helper.Logger("Find one data store", filePath, err)
		return dto.StoreResponse{}, errors.New(BASE_MESSAGE)
	}

	store := dto.StoreData{
		Id:          dataStore.ID,
		Name:        dataStore.Name,
		PhoneNumber: *dataStore.PhoneNumber,
		Coordinate:  *dataStore.Coordinate,
		OpenHour:    dataStore.OpenHour,
		CloseHour:   dataStore.CloseHour,
		BannerUrl:   *dataStore.BannerUrl,
		Address:     *dataStore.Address,
		Description: *dataStore.Description,
		CreatedAt:   dataStore.CreatedAt,
	}

	var scopes []func(*gorm.DB) *gorm.DB
	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Where("id_store = ?", dataStore.ID)
	})

	if claims.Role == entity.RoleCustomer {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("status = ?", entity.CapsterStatusActive)
		})
	}

	var services []dto.ServiceData

	dataServices, err := s.serviceRepo.FindAll(scopes...)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find all services", filePath, err)
		return dto.StoreResponse{}, errors.New(BASE_MESSAGE)
	}

	if err == nil {
		for _, s := range dataServices {
			services = append(services, dto.ServiceData{
				Id:              s.ID,
				Name:            s.Name,
				Price:           s.Price,
				DurationMinutes: s.DurationMinutes,
				DoDont:          s.DoDont,
				Description:     s.Description,
				Status:          s.Status,
			})
		}
	}

	var packages []dto.PackageData
	dataPackages, err := s.packageRepo.FindAll(scopes...)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find all packaages", filePath, err)
		return dto.StoreResponse{}, errors.New(BASE_MESSAGE)
	}

	if err == nil {
		for _, s := range dataPackages {
			packages = append(packages, dto.PackageData{
				Id:              s.ID,
				Name:            s.Name,
				Price:           s.Price,
				DoDont:          s.DoDont,
				DurationMinutes: s.DurationMinutes,
				Description:     s.Description,
				Status:          s.Status,
			})
		}
	}

	dataRatings, err := s.ratingRepo.FindAll("id_store = ?", idStore)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find all ratings", filePath, err)
		return dto.StoreResponse{}, errors.New(BASE_MESSAGE)
	}

	var avgRating float64
	var reviews []dto.Review
	if err == nil {
		var totalRatings int16
		for _, v := range dataRatings {
			totalRatings += v.Score
			reviews = append(reviews, dto.Review{
				Id:      v.ID,
				Message: *v.Message,
				Rating:  v.Score,
				User: dto.CustomerResponseRating{
					Id:          v.Customer.ID,
					Name:        v.Customer.Name,
					ImageUrl:    v.Customer.ImageCustomer,
					PremiumType: v.Customer.PremiumType,
				},
			})
		}

		if len(dataRatings) > 0 {
			avgRating = float64(totalRatings) / float64(len(dataRatings))
		}
	}

	dataCapsters, err := s.capsterRepo.FindAll(scopes...)

	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find all data capsters", filePath, err)
		return dto.StoreResponse{}, errors.New(BASE_MESSAGE)
	}

	var capsters []dto.CapsterDataResponse

	if err == nil {
		for _, v := range dataCapsters {
			var totalRatings int16
			for _, rating := range v.Ratings {
				totalRatings += (rating.Score)
			}

			var avgRating float64

			if len(v.Ratings) > 0 {
				avgRating = float64(totalRatings) / float64(len(v.Ratings))
			}

			capsters = append(capsters, dto.CapsterDataResponse{
				Id:        v.ID,
				Name:      v.Name,
				Title:     v.Title,
				Status:    v.Status,
				ImageUrl:  *v.ImageUrl,
				AvgRating: avgRating,
			})
		}
	}

	return dto.StoreResponse{
		Store:   store,
		Service: services,
		Package: packages,
		Rating: dto.RatingResponseData{
			AvgRating: avgRating,
			Review:    reviews,
		},
		Capster: capsters,
	}, nil
}

func (s *storeService) UpdateStore(req dto.UpdateStoreRequest, storeId string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengupdate data toko!"
	_, filePath, _, _ := runtime.Caller(0)

	id, err := uuid.Parse(storeId)
	if err != nil {
		return errors.New("Id toko tidak valid")
	}

	_, err = s.storeRepo.FindOne("id = ?", id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko cabang yang anda ingin ubah tidak ditemukan atau telah dihapus")
		}

		helper.Logger("Find data store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	coordinate := fmt.Sprintf("%f,%f", req.Lat, req.Long)

	store := entity.Store{
		ID:          id,
		Name:        req.Name,
		PhoneNumber: &req.PhoneNumber,
		Coordinate:  &coordinate,
		OpenHour:    req.OpenHour,
		CloseHour:   req.CloseHour,
		BannerUrl:   &req.BannerUrl,
		Address:     &req.Address,
		Description: req.Description,
		Status:      req.Status,
	}

	err = s.storeRepo.Update(&store)
	if err != nil {
		helper.Logger("Find data store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
