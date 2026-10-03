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

type RatingService interface {
	Create(req dto.CreateRatingRequest, claims *lib.CustomClaims) error
}

type ratingService struct {
	ratingRepo  repository.RatingRepository
	bookingRepo repository.BookingRepository
	capsterRepo repository.CapsterRepository
	staffRepo   repository.StaffRepository
	storeRepo   repository.StoreRepository
	db          *gorm.DB
}

func NewRatingService(
	rr repository.RatingRepository,
	br repository.BookingRepository,
	cr repository.CapsterRepository,
	sr repository.StaffRepository,
	str repository.StoreRepository,
	db *gorm.DB,

) RatingService {
	return &ratingService{
		ratingRepo:  rr,
		bookingRepo: br,
		db:          db,
		capsterRepo: cr,
		staffRepo:   sr,
		storeRepo:   str,
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

	if req.Rating.Capster == nil && req.Rating.Staff == nil && req.Rating.Store == nil {
		return errors.New("Mohon menilai setidaknya satu dari toko, capster, atau staff kami.")
	}

	_, err = s.bookingRepo.FindOne("id = ? AND status_booking = ?", idBooking, entity.BookingStatusCompleted)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Booking tidak ditemukan!")
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

			_, err = s.capsterRepo.FindOne("id = ?", idCapster)
			if err != nil {
				return err
			}

			_, err = s.ratingRepo.FindOne("id_booking = ? AND id_capster = ?", idBooking, idCapster)
			if err != nil {
				if !errors.Is(err, gorm.ErrRecordNotFound) {
					return err
				}

				dataRating.IDCapster = &idCapster
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

			_, err = s.ratingRepo.FindOne("id_booking = ? AND id_staff = ?", idBooking, idStaff)
			if err != nil {
				if !errors.Is(err, gorm.ErrRecordNotFound) {
					return err
				}

				dataRating.IDCapster = nil
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

			dataRatingRegistered, err := s.ratingRepo.FindOne("id_booking = ? AND id_store = ?", idBooking, idStore)
			if err != nil {
				if !errors.Is(err, gorm.ErrRecordNotFound) {
					return err
				}

				dataRating.IDCapster = nil
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
