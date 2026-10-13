package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"context"
	"errors"
	"log"
	"runtime"
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

type EmployeeService interface {
	CreateEmployee(ctx context.Context, req dto.CreateEmployeeReq) error
}

type employeeService struct {
	employeeRepo repository.EmployeeRepository
	positionRepo repository.PositionRepository
	storeRepo    repository.StoreRepository
	db           *gorm.DB
}

func NewEmployeeService(
	er repository.EmployeeRepository,
	pr repository.PositionRepository,
	sr repository.StoreRepository,
	d *gorm.DB,
) EmployeeService {
	return &employeeService{
		employeeRepo: er,
		positionRepo: pr,
		storeRepo:    sr,
		db:           d,
	}
}

func (s *employeeService) validateAgeEmployee(dateOfBirth time.Time) bool {
	now := time.Now()

	age := now.Year() - dateOfBirth.Year()

	if now.Month() < dateOfBirth.Month() ||
		(now.Month() == dateOfBirth.Month() &&
			now.Day() < dateOfBirth.Day()) {
		age--
	}

	return age >= 20 && age <= 35
}

func (s *employeeService) CreateEmployee(ctx context.Context, req dto.CreateEmployeeReq) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat karyawan baru."
	_, filePath, _, _ := runtime.Caller(0)

	if !s.validateAgeEmployee(req.DateOfBirth) {
		return errors.New("Minimum usia adalah 20 tahun & max usia 35 tahun.")
	}

	if _, err := helper.ValidateIdentityNumber(req.NationalIdNumber); err != nil {
		return err
	}

	idPosition, err := uuid.Parse(req.IdPosition)
	if err != nil {
		return errors.New("Posisi id tidak valid.")
	}

	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return errors.New("Id toko tidak valid.")
	}

	_, err = s.positionRepo.FindOne("id = ?", idPosition)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Posisi tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("find one position", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	_, err = s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("find one store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	var imageUrl *string
	if req.ImageUrl != nil {
		permanentKey, err := lib.MoveObjectToPermanent(ctx, *req.ImageUrl)
		if err != nil {
			return err
		}

		imageUrl = &permanentKey
	}

	identityKeyUrl, err := lib.MoveObjectToPermanent(ctx, req.IdentityDocumentUrl)
	if err != nil {
		log.Println("Cihuy")
		return err
	}

	basicSalary := decimal.NewFromFloat(req.BasicSalary)

	var (
		ErrPhoneTaken      = errors.New("nomor telepon sudah terdaftar")
		ErrEmailTaken      = errors.New("email sudah terdaftar")
		ErrNationalIDTaken = errors.New("NIK sudah terdaftar")
		ErrEmployeeExists  = errors.New("data karyawan sudah terdaftar")
	)

	var employeeUniqueErrors = map[string]error{
		"email_employee_unique":              ErrPhoneTaken,
		"employee_phone_number_unique":       ErrEmailTaken,
		"national_id_number_employee_unique": ErrNationalIDTaken,
	}

	err = s.db.Transaction(func(tx *gorm.DB) error {
		newEmployee := entity.Employee{
			ID:                  uuid.New(),
			IdPosition:          idPosition,
			IdStore:             &idStore,
			Name:                req.Name,
			PhoneNumber:         &req.PhoneNumber,
			BasicSalary:         &basicSalary,
			Email:               &req.Email,
			Gender:              &req.Gender,
			DateOfBirth:         &req.DateOfBirth,
			Address:             req.Address,
			Status:              entity.EmployeeStatusActive,
			NationalIDNumber:    &req.NationalIdNumber,
			ImageUrl:            imageUrl,
			IdentityDocumentUrl: &identityKeyUrl,
		}

		err = s.employeeRepo.Create(tx, &newEmployee)
		if err != nil {
			if constraint, ok := helper.UniqueViolationConstraint(err); ok {
				if mapped, found := employeeUniqueErrors[constraint]; found {
					return mapped
				}
				return ErrEmployeeExists
			}
			return err
		}

		return nil
	})

	if err != nil {
		if errors.Is(err, ErrEmailTaken) {
			return err
		}

		if errors.Is(err, ErrPhoneTaken) {
			return err
		}

		if errors.Is(err, ErrNationalIDTaken) {
			return err
		}

		if errors.Is(err, ErrEmployeeExists) {
			return err
		}

		helper.Logger("Create employee", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
