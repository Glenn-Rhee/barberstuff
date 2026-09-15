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
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type StoreService interface {
	CreateNewStore(req dto.NewStoreRequest) error
	GetStores(query dto.QueryParamsStores, claims *lib.CustomClaims) ([]dto.StoreData, dto.ResponsePagination, error)
	GetStore(claims lib.CustomClaims, idStore string) (dto.StoreData, error)
	UpdateStore(req dto.UpdateStoreRequest, storeId string) error
	DeleteStore(storeId string) error
}

type storeService struct {
	storeRepo   repository.StoreRepository
	serviceRepo repository.ServiceRepository
	ratingRepo  repository.RatingRepository
	capsterRepo repository.CapsterRepository
	staffRepo   repository.StaffRepository
}

func NewStoreService(
	storeRepo repository.StoreRepository,
	sr repository.ServiceRepository,
	rr repository.RatingRepository,
	cr repository.CapsterRepository,
	str repository.StaffRepository,
) StoreService {
	return &storeService{
		storeRepo:   storeRepo,
		serviceRepo: sr,
		ratingRepo:  rr,
		capsterRepo: cr,
		staffRepo:   str,
	}
}

func derefString(s *string) string {
	if s == nil {
		return ""
	}
	return *s
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

	_, err = time.LoadLocation(string(req.Timezone))
	if err != nil {
		return errors.New("Timezone tidak valid!")
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
		StoreType:   req.StoreType,
	}

	err = s.storeRepo.Create(&store)
	if err != nil {
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *storeService) GetStores(query dto.QueryParamsStores, claims *lib.CustomClaims) ([]dto.StoreData, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data toko!"
	_, filePath, _, _ := runtime.Caller(0)

	var scopes []func(*gorm.DB) *gorm.DB
	if query.NameStore != nil {
		q := "%"
		q += *query.NameStore
		q += "%"
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("name ILIKE ?", q)
		})
	}

	if claims.Role == entity.RoleCustomer {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("status = ?", entity.StoreStatusOpen)
		})
	}

	var page = 1
	var limit = 20
	var sortBy = dto.SortByName
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
		return d.Where("deleted_at IS NULL")
	})

	totalData, err := s.storeRepo.Count(scopes...)
	if err != nil {
		helper.Logger("Count total store repo", filePath, err)
		return []dto.StoreData{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Clauses(clause.OrderBy{
			Columns: []clause.OrderByColumn{
				{Column: clause.Column{Name: string(sortBy)}, Desc: dto.SortStore(orderBy) == "desc"},
			},
		}).Offset((page - 1) * limit).Limit(limit)
	})

	paginationData := helper.GetPaginationData(page, limit, int(totalData))
	stores, err := s.storeRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("Find all data", filePath, err)
		return []dto.StoreData{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	dataStores := make([]dto.StoreData, 0, len(stores))
	for _, s := range stores {
		var reviews []dto.Review
		var totalRating = 0
		var avgRating float64 = 5.0
		for _, v := range s.Ratings {
			totalRating += int(v.Score)
			reviews = append(reviews, dto.Review{
				Id:      v.ID,
				Message: v.Message,
				Rating:  v.Score,
				User: dto.CustomerResponseRating{
					Id:          v.Customer.ID,
					Name:        v.Customer.Name,
					ImageUrl:    v.Customer.ImageCustomer,
					PremiumType: v.Customer.PremiumType.Name,
				},
			})
		}
		if len(s.Ratings) > 0 {
			avgRating = float64(totalRating) / float64(len(s.Ratings))
		}

		dataStores = append(dataStores, dto.StoreData{
			Id:           s.ID,
			Name:         s.Name,
			PhoneNumber:  (s.PhoneNumber),
			Coordinate:   (s.Coordinate),
			OpenHour:     s.OpenHour,
			CloseHour:    s.CloseHour,
			BannerUrl:    (s.BannerUrl),
			Address:      (s.Address),
			Status:       s.Status,
			Description:  (s.Description),
			StoreType:    s.StoreType,
			CreatedAt:    s.CreatedAt,
			TotalPackage: s.TotalPackage,
			TotalCapster: s.TotalCapster,
			TotalService: s.TotalService,
			Review:       reviews,
			AvgRating:    avgRating,
		})
	}

	return dataStores, paginationData, nil
}

func (s *storeService) GetStore(claims lib.CustomClaims, idStore string) (dto.StoreData, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data toko!"
	_, filePath, _, _ := runtime.Caller(0)

	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.StoreData{}, errors.New("Data toko cabang yang anda cari tidak ditemukan!")
		}

		helper.Logger("Find one data store", filePath, err)
		return dto.StoreData{}, errors.New(BASE_MESSAGE)
	}

	dataRatings, err := s.ratingRepo.FindAll("id_store = ?", idStore)
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find all ratings", filePath, err)
		return dto.StoreData{}, errors.New(BASE_MESSAGE)
	}

	var avgRating float64 = 5.0
	var reviews []dto.Review
	if err == nil {
		var totalRatings int16
		for _, v := range dataRatings {
			totalRatings += v.Score
			reviews = append(reviews, dto.Review{
				Id:      v.ID,
				Message: v.Message,
				Rating:  v.Score,
				User: dto.CustomerResponseRating{
					Id:          v.Customer.ID,
					Name:        v.Customer.Name,
					ImageUrl:    v.Customer.ImageCustomer,
					PremiumType: v.Customer.PremiumType.Name,
				},
			})
		}

		if len(dataRatings) > 0 {
			avgRating = float64(totalRatings) / float64(len(dataRatings))
		}
	}

	store := dto.StoreData{
		Id:           dataStore.ID,
		Name:         dataStore.Name,
		PhoneNumber:  dataStore.PhoneNumber,
		Coordinate:   dataStore.Coordinate,
		OpenHour:     dataStore.OpenHour,
		CloseHour:    dataStore.CloseHour,
		BannerUrl:    dataStore.BannerUrl,
		Address:      dataStore.Address,
		Description:  dataStore.Description,
		Status:       dataStore.Status,
		CreatedAt:    dataStore.CreatedAt,
		TotalService: dataStore.TotalService,
		TotalCapster: dataStore.TotalCapster,
		TotalPackage: dataStore.TotalPackage,
		StoreType:    dataStore.StoreType,
		AvgRating:    avgRating,
		Review:       reviews,
	}

	return store, nil
}

func (s *storeService) UpdateStore(req dto.UpdateStoreRequest, storeId string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengupdate data toko!"
	_, filePath, _, _ := runtime.Caller(0)

	id, err := uuid.Parse(storeId)
	if err != nil {
		return errors.New("Id toko tidak valid")
	}

	dataStore, err := s.storeRepo.FindOne("id = ?", id)
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
		CreatedAt:   dataStore.CreatedAt,
		DeletedAt:   dataStore.DeletedAt,
	}

	err = s.storeRepo.Update(&store)
	if err != nil {
		helper.Logger("Find data store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *storeService) DeleteStore(storeId string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat menghapus data toko!"
	_, filePath, _, _ := runtime.Caller(0)

	id, err := uuid.Parse(storeId)
	if err != nil {
		return errors.New("Id toko tidak valid")
	}

	dataStore, err := s.storeRepo.FindOne("id = ?", id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko cabang yang anda ingin hapus tidak ditemukan atau telah dihapus")
		}

		helper.Logger("Find data store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if dataStore.DeletedAt != nil {
		return errors.New("Toko ini telah dihapus!")
	}

	err = s.storeRepo.SoftDelete(id)
	if err != nil {
		helper.Logger("Delete store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
