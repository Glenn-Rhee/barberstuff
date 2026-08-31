package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/repository"
	"errors"
	"runtime"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type StaffService interface {
	CreateAdmin(req dto.StaffRequest) error
}

type staffService struct {
	staffRepo repository.StaffRepository
	authRepo  repository.AuthenticationRepository
	db        *gorm.DB
}

func NewStaffService(sr repository.StaffRepository, ar repository.AuthenticationRepository, db *gorm.DB) StaffService {
	return &staffService{staffRepo: sr, authRepo: ar, db: db}
}

func (s *staffService) CreateAdmin(req dto.StaffRequest) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat data admin"
	_, filePath, _, _ := runtime.Caller(0)

	dataAuth, err := s.authRepo.FindOne("email = ?", req.Email)
	if err == nil {
		if dataAuth.Role != entity.RoleAdmin {
			return errors.New("Email ini telah terdaftar!")
		}

		return errors.New("Akun admin telah terdaftar! Tidak dapat mendaftar kembali")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find data staff", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	_, err = s.authRepo.FindOne("role = ?", entity.RoleAdmin)
	if err == nil {
		return errors.New("Akun admin telah terdaftar! Tidak dapat mendaftar kembali")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find data staff", filePath, err)
		return errors.New(BASE_MESSAGE)
	}
	
	hashedPassword, err := helper.HashPassword(req.Password)
	if err != nil {
		helper.Logger("Hashed password", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	tx := s.db.Begin()
	if tx.Error != nil {
		helper.Logger("Begin tx", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	adminId := uuid.New()

	admin := entity.Staff{
		ID:   adminId,
		Name: req.Name,
	}

	adminAuth := entity.Authentication{
		ID:         uuid.New(),
		IDStaff:    &adminId,
		Password:   hashedPassword,
		Role:       entity.RoleAdmin,
		Email:      req.Email,
		IsVerified: true,
		LoginType:  entity.LoginWithCredential,
	}

	err = s.staffRepo.Create(tx, &admin)
	if err != nil {
		tx.Rollback()
		helper.Logger("Create data staff", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	err = s.authRepo.Create(tx, &adminAuth)
	if err != nil {
		tx.Rollback()
		helper.Logger("Create data auth", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	tx.Commit()
	return nil
}
