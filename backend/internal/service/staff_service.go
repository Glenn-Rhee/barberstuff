package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/repository"
	"errors"
	"fmt"
	"log"
	"os"
	"runtime"

	"github.com/google/uuid"
	"github.com/joho/godotenv"
	"gorm.io/gorm"
)

type StaffService interface {
	CreateAdmin(req dto.StaffRequest) error
	CreateAccout(req dto.CreateAccountStaffRequest) error
}

type staffService struct {
	staffRepo repository.StaffRepository
	authRepo  repository.AuthenticationRepository
	storeRepo repository.StoreRepository
	db        *gorm.DB
}

func NewStaffService(str repository.StoreRepository, sr repository.StaffRepository, ar repository.AuthenticationRepository, db *gorm.DB) StaffService {
	return &staffService{staffRepo: sr, authRepo: ar, db: db, storeRepo: str}
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

func (s *staffService) CreateAccout(req dto.CreateAccountStaffRequest) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat akun staff"
	_, filePath, _, _ := runtime.Caller(0)
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}

	BASE_PASSWORD := os.Getenv("BASE_PASSWORD_STAFF")
	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return errors.New("Format id toko tidak valid!")
	}

	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Data toko cabang tidak ditemukan atau telah dihapus")
		}

		helper.Logger("Find data store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	dataAuth, err := s.authRepo.FindOne("email = ?", req.Email)

	if err == nil {
		if dataAuth.Role == req.Role {
			return errors.New("Email ini telah terdaftar!")
		}

		return errors.New("Akun staff telah terdaftar! Tidak dapat mendaftar kembali")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find data auth", filePath, err)
		return errors.New(BASE_MESSAGE)
	}
	var scopes []func(*gorm.DB) *gorm.DB
	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Where("id_store = ?", dataStore.ID)
	})
	dataStaffes, err := s.staffRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("Find all staff", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if len(dataStaffes) >= 2 {
		return errors.New("Batas akun toko penuh (maks. 2 akun)")
	}

	var isRegistered bool = false
	for _, v := range dataStaffes {
		if v.Authentication.Role == req.Role {
			isRegistered = true
		}
	}

	if isRegistered {
		return fmt.Errorf("Role %s untuk toko %s telah terdaftar", req.Role, dataStore.Name)
	}

	hashedPassword, err := helper.HashPassword(BASE_PASSWORD)
	if err != nil {
		helper.Logger("Hash password", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	err = s.db.Transaction(func(tx *gorm.DB) error {
		newStaff := entity.Staff{
			ID:      uuid.New(),
			Name:    req.Name,
			IdStore: &idStore,
		}

		if err := tx.Create(&newStaff).Error; err != nil {
			return err
		}

		newAuth := entity.Authentication{
			ID:         uuid.New(),
			IDStaff:    &newStaff.ID,
			Password:   hashedPassword,
			Role:       req.Role,
			Email:      req.Email,
			IsVerified: true,
			LoginType:  entity.LoginWithCredential,
		}

		if err := tx.Create(&newAuth).Error; err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		helper.Logger("Creattae staff and auth", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
