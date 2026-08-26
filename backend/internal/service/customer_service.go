package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
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
	VerifyOTP(dataOTPCust dto.VerifyCredentialRequest) error
}

type customerService struct {
	customerRepo repository.CustomerRepository
	authRepo     repository.AuthenticationRepository
	otpRepo      repository.OtpRepository
	db           *gorm.DB
}

const defaultRegisterErrMsg = "Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!"

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
		return &dto.CredentialCustomerResponse{}, errors.New(defaultRegisterErrMsg)
	}

	dataAuth, err := c.authRepo.GetByEmail(dataNewCustomer.Email)
	if err == nil {
		if dataAuth.IsVerified {
			return &dto.CredentialCustomerResponse{}, errors.New("Email ini telah terdaftar dan terverifikasi!")
		}

		if waitErr := c.checkPendingOTP(*dataAuth.IDCustomer); waitErr != nil {
			tx.Rollback()
			return &dto.CredentialCustomerResponse{}, waitErr
		}
		
		otpData, err := c.issueOTP(tx, *dataAuth.IDCustomer)
		if err != nil {
			return c.failRegister(tx, "ISSUE OTP", err)
		}

		dataCustomer, err := c.customerRepo.FindById(dataAuth.IDCustomer.String())
		if err != nil {
			return c.failRegister(tx, "GET DATA CUSTOMER", err)
		}

		err = c.sendOtp(*otpData, dataAuth.Email, dataNewCustomer.Name)
		if err != nil {
			return c.failRegister(tx, "Send OTP", err)
		}

		tx.Commit()
		return &dto.CredentialCustomerResponse{
			Id:       dataAuth.IDCustomer.String(),
			Username: dataCustomer.Username,
			Email:    dataAuth.Email,
		}, nil
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return c.failRegister(tx, "GET EMAIL", err)
	}

	if _, err := c.customerRepo.GetByUsername(dataNewCustomer.Username); err == nil {
		tx.Rollback()
		return &dto.CredentialCustomerResponse{}, errors.New("Username telah terdaftar")
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		return c.failRegister(tx, "GET USERNAME", err)
	}

	hashedPassword, err := helper.HashPassword(dataNewCustomer.Password)
	if err != nil {
		return c.failRegister(tx, "GENERATE HASH PASSWORD", err)
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

	if err := c.customerRepo.Create(tx, customer); err != nil {
		return c.failRegister(tx, "CREATE CUSTOMER", err)
	}
	if err := c.authRepo.Create(tx, auth); err != nil {
		return c.failRegister(tx, "CREATE AUTHENTICATION", err)
	}

	otpData, err := c.issueOTP(tx, custId)
	if err != nil {
		return c.failRegister(tx, "ISSUE OTP", err)
	}

	err = c.sendOtp(*otpData, auth.Email, customer.Name)
	if err != nil {
		return c.failRegister(tx, "Send OTP", err)
	}

	tx.Commit()
	return &dto.CredentialCustomerResponse{
		Id:       custId.String(),
		Username: dataNewCustomer.Username,
		Email:    dataNewCustomer.Email,
	}, nil
}

func (c *customerService) VerifyOTP(dataOTPCust dto.VerifyCredentialRequest) error {
	const MESSAGE_ERROR = "Terjadi kesalahan saat verifikasi otp. Coba lagi nanti"
	parsedId, err := uuid.Parse(dataOTPCust.UserId)
	if err != nil {
		helper.Logger("Parsed string -> UUID", "service/customer_service.go", err)
		return errors.New(MESSAGE_ERROR)
	}

	dataOtpRegistered, err := c.otpRepo.FindByUserId(parsedId)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Data tidak ditemukan! Mohon daftar ulang!")
		}
		helper.Logger("Find otp By user id", "service/customer_service.go", err)
		return errors.New(MESSAGE_ERROR)
	}

	remaining := time.Until(dataOtpRegistered.ExpiredAt)
	if remaining <= 0 {
		return errors.New("OTP Sudah tidak valid. Mohon kirim ulang OTP!")
	}

	if dataOtpRegistered.OTP != dataOTPCust.OTP {
		err = c.otpRepo.IncrementAttempt(parsedId)
		if err != nil {
			helper.Logger("Increment attempt otp", "service/customer_service.go", err)
			return errors.New(MESSAGE_ERROR)
		}
		if dataOtpRegistered.AttempCount == 4 {
			tx := c.db.Begin()
			err = c.otpRepo.Delete(tx, parsedId)
			if err != nil {
				tx.Rollback()
				helper.Logger("Delete OTP, attempt count > 5", "service/customer_service.go", err)
				return errors.New(MESSAGE_ERROR)
			}
			tx.Commit()
			return errors.New("Anda telah melakukan kesalahan 5 kali percobaan! Mohon untuk kirim ulang OTP!")
		}
		return fmt.Errorf("OTP Tidak valid, silahkan coba lagi. Sisa percobaan %d kali", 4-dataOtpRegistered.AttempCount)
	}

	tx := c.db.Begin()
	err = c.otpRepo.Delete(tx, parsedId)
	if err != nil {
		tx.Rollback()
		helper.Logger("Delete OTP while OTP is correct!", "service/customer_service.go", err)
		return errors.New(MESSAGE_ERROR)
	}
	err = c.authRepo.UpdateVerifiedCredential(tx, parsedId, true)
	if err != nil {
		tx.Rollback()
		helper.Logger("Update verified", "service/customer_service.go", err)
		return errors.New(MESSAGE_ERROR)
	}
	tx.Commit()

	return nil
}

func (c *customerService) sendOtp(otpData entity.OTP, email string, name string) error {
	remaining := time.Until(otpData.ExpiredAt)
	minutes := int(remaining.Minutes())

	err := lib.SendEmailToUser(lib.EmailOptions{
		To:           []string{email},
		Subject:      "Kode OTP Barberstuff",
		TemplateName: "otp.html",
		TemplateData: map[string]interface{}{
			"AppName":       "Barberstuff",
			"Name":          name,
			"OTPCode":       otpData.OTP,
			"ExpiryMinutes": minutes,
		},
	})

	return err
}

func (c *customerService) failRegister(tx *gorm.DB, label string, err error) (*dto.CredentialCustomerResponse, error) {
	tx.Rollback()
	log.Printf(label, err)
	return &dto.CredentialCustomerResponse{}, errors.New(defaultRegisterErrMsg)
}

func (c *customerService) checkPendingOTP(userId uuid.UUID) error {
	otpRegistered, err := c.otpRepo.FindByUserId(userId)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil // aman, boleh lanjut generate baru
		}
		return err // error tak terduga
	}

	remaining := time.Until(otpRegistered.ExpiredAt)
	if remaining > 0 {
		minutes := int(remaining.Minutes())
		seconds := int(remaining.Seconds()) % 60
		return fmt.Errorf("Tunggu %d menit %d detik sebelum meminta OTP baru", minutes, seconds)
	}

	return nil
}

func (c *customerService) issueOTP(tx *gorm.DB, userId uuid.UUID) (*entity.OTP, error) {
	otpGenerated, err := helper.GenerateOTP()
	if err != nil {
		return nil, err
	}

	otp := &entity.OTP{
		ID:          uuid.New(),
		IDUser:      userId,
		OTP:         otpGenerated,
		AttempCount: 0,
		ExpiredAt:   time.Now().Add(3 * time.Minute),
	}

	if err := c.otpRepo.Upsert(tx, otp); err != nil {
		return nil, err
	}

	return otp, nil
}
