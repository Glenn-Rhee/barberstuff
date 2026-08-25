package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/repository"
	"errors"
	"fmt"
	"log"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type CustomerService interface {
	CredentialRegister(dataNewCustomer dto.CredentialCustomerRequest) (*dto.CredentialCustomerResponse, error)
}

type customerService struct {
	customerRepo repository.CustomerRepository
	authRepo     repository.AuthenticationRepository
	otpRepo      repository.OtpRepository
	db           *gorm.DB
}

func NewCustomerService(custRepo repository.CustomerRepository, authRepo repository.AuthenticationRepository, db *gorm.DB, otpRepo repository.OtpRepository) CustomerService {
	return &customerService{
		customerRepo: custRepo,
		authRepo:     authRepo,
		otpRepo:      otpRepo,
		db:           db,
	}
}

func (c *customerService) CredentialRegister(dataNewCustomer dto.CredentialCustomerRequest) (*dto.CredentialCustomerResponse, error) {
	tx := c.db.Begin()

	if tx.Error != nil {
		log.Println("Error [START TRANSAKSI] [service/customer_service.go]:", tx.Error.Error())
		return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!")
	}

	dataAuth, err := c.authRepo.GetByEmail(dataNewCustomer.Email)
	if err == nil {
		// Email sudah ada tapi sudah verified
		if dataAuth.IsVerified {
			return &dto.CredentialCustomerResponse{}, errors.New("Email telah terdaftar")
		}

		// Todo, email sudah ada tapi belum verified
		otpRegistered, err := c.otpRepo.FindByUserId(*dataAuth.IDCustomer)
		// OTP Sudah ada
		if err == nil {
			remaining := time.Until(otpRegistered.ExpiredAt)
			// OTP masih valid
			if remaining > 0 {
				minutes := int(remaining.Minutes())
				seconds := int(remaining.Seconds()) % 60
				return &dto.CredentialCustomerResponse{}, fmt.Errorf("Tunggu %d menit %d detik sebelum meminta OTP baru", minutes, seconds)
			}
		}

		// OTP udh ga valid, hapus data otp
		err = c.otpRepo.Delete(tx, *dataAuth.IDCustomer)
		if err != nil {
			tx.Rollback()
			log.Println("Error [DELETE OTP] [service/customer_service.go]:", err.Error())
			return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!")
		}

		otpGenerated, err := helper.GenerateOTP()
		if err != nil {
			tx.Rollback()
			log.Println("Error [GENERATE OTP] [service/customer_service.go]:", err.Error())
			return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!")
		}

		otp := &entity.OTP{
			ID:        uuid.New(),
			IDUser:    *dataAuth.IDCustomer,
			OTP:       otpGenerated,
			ExpiredAt: time.Now().Add(3 * time.Minute),
		}

		_, err = c.otpRepo.Create(tx, otp)
		if err != nil {
			tx.Rollback()
			log.Println("Error [STORE OTP] [service/customer_service.go]:", err.Error())
			return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!")
		}

		dataCustomer, err := c.customerRepo.FindById(dataAuth.IDCustomer.String())
		if err != nil {
			tx.Rollback()
			log.Println("Error [GET DATA CUSTOMER] [service/customer_service.go]:", err.Error())
			return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!")
		}

		tx.Commit()
		return &dto.CredentialCustomerResponse{
			Id:       dataAuth.IDCustomer.String(),
			Username: dataCustomer.Username,
			Email:    dataAuth.Email,
		}, nil
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		log.Println("Error [GET EMAIL] [service/customer_service.go]:", err.Error())
		return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!")
	}

	_, err = c.customerRepo.GetByUsername(dataNewCustomer.Username)
	if err == nil {
		return &dto.CredentialCustomerResponse{}, errors.New("Username telah terdaftar")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		log.Println("Error [GET USERNAME] [service/customer_service.go]:", err.Error())
		return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!")
	}

	hashedPassword, err := helper.HashPassword(dataNewCustomer.Password)
	if err != nil {
		log.Println("Error [GENERATE HASH PASSWORD] [service/customer_service.go]:", err.Error())
		return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!")
	}

	custId := uuid.New()

	customer := &entity.Customer{
		ID:           custId,
		Name:         dataNewCustomer.Name,
		PhoneNumber:  &dataNewCustomer.PhoneNumber,
		DateOfBirth:  &dataNewCustomer.DateOfBirth,
		Gender:       dataNewCustomer.Gender,
		Username:     dataNewCustomer.Username,
		MemberPoints: 100,
	}

	auth := &entity.Authentication{
		ID:            uuid.New(),
		IDCustomer:    &custId,
		Password:      hashedPassword,
		Role:          entity.RoleCustomer,
		Email:         dataNewCustomer.Email,
		IsVerified:    false,
		LoginType:     entity.LoginWithCredential,
		OAuthProvider: "",
	}

	err = c.customerRepo.Create(tx, customer)
	if err != nil {
		tx.Rollback()
		log.Println("Error [CREATE CUSTOMER] [service/customer_service.go]:", err.Error())
		return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!")
	}

	err = c.authRepo.Create(tx, auth)
	if err != nil {
		tx.Rollback()
		log.Println("Error [CREATE AUTHENTICATION] [service/customer_service.go]:", err.Error())
		return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!")
	}

	otpGenerated, err := helper.GenerateOTP()
	if err != nil {
		log.Println("Error [CREATE OTP] [service/customer_service.go]:", err.Error())
		return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!")
	}

	otp := &entity.OTP{
		ID:        uuid.New(),
		IDUser:    custId,
		OTP:       otpGenerated,
		ExpiredAt: time.Now().Add(3 * time.Minute),
	}

	_, err = c.otpRepo.Create(tx, otp)
	if err != nil {
		log.Println("Error [STORE OTP] [service/customer_service.go]:", err.Error())
		return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!")
	}

	// Ceritanya kirim email

	tx.Commit()

	return &dto.CredentialCustomerResponse{
		Id:       custId.String(),
		Username: dataNewCustomer.Username,
		Email:    dataNewCustomer.Email,
	}, nil
}
