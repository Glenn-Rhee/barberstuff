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
	"gorm.io/gorm/clause"
)

type RatingService interface {
	Create(req dto.CreateRatingRequest, claims *lib.CustomClaims) error
	GetRatings(req dto.GetRatingReq) ([]dto.GetRatingRes, dto.ResponsePagination, error)
}

type ratingService struct {
	ratingRepo   repository.RatingRepository
	bookingRepo  repository.BookingRepository
	employeeRepo repository.EmployeeRepository
	staffRepo    repository.StaffRepository
	storeRepo    repository.StoreRepository
	db           *gorm.DB
}

func NewRatingService(
	rr repository.RatingRepository,
	br repository.BookingRepository,
	er repository.EmployeeRepository,
	sr repository.StaffRepository,
	str repository.StoreRepository,
	db *gorm.DB,
) RatingService {
	return &ratingService{
		ratingRepo:   rr,
		bookingRepo:  br,
		db:           db,
		employeeRepo: er,
		staffRepo:    sr,
		storeRepo:    str,
	}
}

func (s *ratingService) Create(req dto.CreateRatingRequest, claims *lib.CustomClaims) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat data rating!"
	_, filePath, _, _ := runtime.Caller(0)

	idBooking, err := uuid.Parse(req.IdBooking)
	if err != nil {
		return errors.New("Booking tidak valid!")
	}

	idUser, err := uuid.Parse(claims.UserId)
	if err != nil {
		return errors.New("Data tidak valid! Mohon login kembali.")
	}

	if helper.IsAllFieldsNil(req.Rating) {
		return errors.New("Mohon menilai setidaknya satu dari toko, capster, atau staff kami.")
	}

	_, err = s.bookingRepo.FindOne("booking.id = ? AND booking.status_booking = ?", idBooking, entity.BookingStatusCompleted)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Booking tidak ditemukan atau belum selesai.")
		}

		helper.Logger("find one booking", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	err = s.db.Transaction(func(tx *gorm.DB) error {
		dataRating := entity.Rating{
			IDUser:    idUser,
			IDBooking: idBooking,
		}

		if req.Rating.Capster != nil {
			idCapster, err := uuid.Parse(req.Rating.Capster.Id)
			if err != nil {
				return err
			}

			_, err = s.employeeRepo.FindOneCapster("employee.id = ?", idCapster)
			if err != nil {
				return err
			}

			_, err = s.ratingRepo.FindOne("rating.id_booking = ? AND rating.id_employee = ?", idBooking, idCapster)
			if err != nil {
				if !errors.Is(err, gorm.ErrRecordNotFound) {
					return err
				}

				dataRating.IDEmployee = &idCapster
				dataRating.IdStaff = nil
				dataRating.IDStore = nil
				dataRating.Score = int16(req.Rating.Capster.Score)
				dataRating.Type = entity.RatingTypeCapster

				err = s.ratingRepo.Create(tx, &dataRating)
				if err != nil {
					return err
				}
			}

			dataRating.ID = uuid.New()
		}

		if req.Rating.Staff != nil {
			idStaff, err := uuid.Parse(req.Rating.Staff.Id)
			if err != nil {
				return err
			}

			dataStaff, err := s.staffRepo.FindOne("id = ?", idStaff)
			if err != nil {
				return err
			}

			if dataStaff.Authentication.Role != entity.RoleCashier {
				return errors.New("Hanya dapat rating kasir!")
			}

			_, err = s.ratingRepo.FindOne("rating.id_booking = ? AND rating.id_staff = ?", idBooking, idStaff)
			if err != nil {
				if !errors.Is(err, gorm.ErrRecordNotFound) {
					return err
				}

				dataRating.IDEmployee = nil
				dataRating.IdStaff = &idStaff
				dataRating.IDStore = nil
				dataRating.Score = int16(req.Rating.Staff.Score)
				dataRating.Type = entity.RatingTypeStaff

				err = s.ratingRepo.Create(tx, &dataRating)
				if err != nil {
					return err
				}
			}

			dataRating.ID = uuid.New()
		}

		if req.Rating.Store != nil {
			idStore, err := uuid.Parse(req.Rating.Store.Id)
			if err != nil {
				return err
			}

			_, err = s.storeRepo.FindOne("id = ?", idStore)
			if err != nil {
				return err
			}

			dataRatingRegistered, err := s.ratingRepo.FindOne("rating.id_booking = ? AND rating.id_store = ?", idBooking, idStore)
			if err != nil {
				if !errors.Is(err, gorm.ErrRecordNotFound) {
					return err
				}

				dataRating.IDEmployee = nil
				dataRating.IdStaff = nil
				dataRating.IDStore = &idStore
				dataRating.Score = int16(req.Rating.Store.Score)
				dataRating.Type = entity.RatingTypeStore
				dataRating.Message = req.Rating.Store.Message

				err = s.ratingRepo.Create(tx, &dataRating)
				if err != nil {
					return err
				}
			} else {
				err := s.ratingRepo.Updates(map[string]interface{}{
					"message": req.Rating.Store.Message,
				}, dataRatingRegistered.ID)

				if err != nil {
					return err
				}
			}

			dataRating.ID = uuid.New()
		}
		return nil
	})

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Data tidak ditemukan atau telah dihapus!")
		}
		helper.Logger("create rating", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *ratingService) GetRatings(req dto.GetRatingReq) ([]dto.GetRatingRes, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat data rating!"
	_, filePath, _, _ := runtime.Caller(0)

	var scopes []func(*gorm.DB) *gorm.DB
	if req.Query != nil {
		q := "%" + *req.Query + "%"
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("message ILIKE ?", q)
		})
	}

	if req.IdTarget != nil {
		IdTarget, err := uuid.Parse(*req.IdTarget)
		if err != nil {
			return []dto.GetRatingRes{}, dto.ResponsePagination{}, errors.New("Id toko tidak valid.")
		}

		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("id_store = ? OR id_employee ? OR id_staff ?", IdTarget, IdTarget, IdTarget)
		})
	}

	if (req.RatingMinScore == nil && req.RatingMaxScore != nil) ||
		(req.RatingMinScore != nil && req.RatingMaxScore == nil) {
		return []dto.GetRatingRes{}, dto.ResponsePagination{}, errors.New("Tidak dapat mengisi hanya salah satu min rating dan max rating saja.")
	}

	if req.RatingMinScore != nil && req.RatingMaxScore != nil {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("score >= ? AND score <= ?", req.RatingMinScore, req.RatingMaxScore)
		})
	}

	var page = 1
	var limit = 20
	var sortBy = dto.RatingByScore
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

	totalData, err := s.ratingRepo.Count(scopes...)
	if err != nil {
		helper.Logger("count total rating", filePath, err)
		return []dto.GetRatingRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Clauses(clause.OrderBy{
			Columns: []clause.OrderByColumn{
				{Column: clause.Column{Name: string(sortBy)}, Desc: orderBy == dto.OrderDesc},
				{Column: clause.Column{Name: "created_at"}},
			},
		}).Offset((page - 1) * limit).Limit(limit)
	})

	paginationData := helper.GetPaginationData(page, limit, int(totalData))
	ratings, err := s.ratingRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("find all ratings", filePath, err)
		return []dto.GetRatingRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	dataRatings := make([]dto.GetRatingRes, 0, len(ratings))
	for _, v := range ratings {
		var imgUrl *string
		if v.Customer.ImageCustomer != nil {
			pressignedUrl, err := lib.GeneratePressignedGetURL(*v.Customer.ImageCustomer)
			if err != nil {
				helper.Logger("generate img url", filePath, err)
			}

			imgUrl = &pressignedUrl
		}

		dataRatings = append(dataRatings, dto.GetRatingRes{
			ID:          v.ID,
			IDCustomer:  v.Customer.ID,
			Name:        v.Customer.Name,
			PremiumType: v.Customer.PremiumType.Name,
			ImageUrl:    imgUrl,
			Score:       int(v.Score),
			Message:     v.Message,
		})
	}

	return dataRatings, paginationData, nil
}
