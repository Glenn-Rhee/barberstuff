package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"context"
	"errors"
	"fmt"
	"log"
	"strconv"
	"time"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
)

type CustomerService interface {
	CredentialRegister(dataNewCustomer dto.CredentialCustomerRequest, ctx context.Context) (*dto.CredentialCustomerResponse, error)
	VerifyOTP(ctx context.Context, dataOTPCust dto.VerifyCredentialRequest) (dto.VerifyOTPResponse, error)
	OauthRegister(dataNewCustomer dto.OauthCustomerRequest, ctx context.Context) (dto.AuthenticationResponse, error)
	ForgotPassword(ctx context.Context, dataForgotPassword dto.ForgotPasswordRequest) (dto.ForgotPassswordResponse, error)
	GetProfile(claims *lib.CustomClaims) (dto.ProfileCustomerResponse, error)
}

type customerService struct {
	customerRepo    repository.CustomerRepository
	authRepo        repository.AuthenticationRepository
	premiumTypeRepo repository.PremiumTypeRepository
	db              *gorm.DB
	client          *redis.Client
}

const defaultRegisterErrMsg = "Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!"
const EXPIRED_OTP = 3 * time.Minute
const MAX_OTP_ATTEMPT = 5
const OTP_ATTEMPT_WINDOW = EXPIRED_OTP*5 + time.Minute // 16 menit
const OTP_BAN_DURATION = 15 * time.Minute

func NewCustomerService(
	custRepo repository.CustomerRepository,
	authRepo repository.AuthenticationRepository,
	db *gorm.DB,
	client *redis.Client,
	ptr repository.PremiumTypeRepository,
) CustomerService {
	return &customerService{
		customerRepo:    custRepo,
		authRepo:        authRepo,
		db:              db,
		client:          client,
		premiumTypeRepo: ptr,
	}
}

func (c *customerService) OauthRegister(dataNewCustomer dto.OauthCustomerRequest, ctx context.Context) (dto.AuthenticationResponse, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat registrasi. Coba lagi nanti."
	const BASE_PATH = "service/customer_service.go"

	claims, err := lib.ParseToken(dataNewCustomer.TempToken)
	if err != nil {
		helper.Logger("Parse temp token", BASE_PATH, err)
		return dto.AuthenticationResponse{}, errors.New(BASE_MESSAGE)
	}

	dataAuth, err := c.authRepo.FindOne("email = ?", claims.Email)
	if err == nil {
		if dataAuth.IsVerified {
			if dataAuth.LoginType == entity.LoginWithOAuth {
				return dto.AuthenticationResponse{}, errors.New("Email ini telah terdaftar dan terverifikasi oleh sistem!")
			}
			return dto.AuthenticationResponse{}, errors.New("Email ini telah terdaftar dan terverifikasi! Silahkan anda login menggunakan password")
		}
	}

	resultDel := c.client.Del(ctx, fmt.Sprintf("temp_token:%v", claims.Email))
	if resultDel.Err() != nil {
		helper.Logger("Delete temp token", BASE_PATH, err)
		return dto.AuthenticationResponse{}, errors.New(BASE_MESSAGE)
	}
	result := c.client.GetDel(ctx, dataNewCustomer.TempToken)

	if result.Err() != nil {
		if errors.Is(result.Err(), redis.Nil) {
			return dto.AuthenticationResponse{}, errors.New("Data anda sudah tidak valid mohon register ulang dengan akun Anda.")
		}

		helper.Logger("Get and delete redis", BASE_PATH, result.Err())
		return dto.AuthenticationResponse{}, errors.New(BASE_MESSAGE)
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find one auth", BASE_PATH, err)
		return dto.AuthenticationResponse{}, errors.New(BASE_MESSAGE)
	}

	dataPremium, err := c.premiumTypeRepo.FindOne("name = ?", "silver")
	if err != nil {
		helper.Logger("Find premium type", BASE_PATH, err)
		return dto.AuthenticationResponse{}, errors.New("Terjadi kesalahan saat mencari data premium")
	}
	custId := uuid.New()
	customer := &entity.Customer{
		ID:            custId,
		Name:          dataNewCustomer.Name,
		PhoneNumber:   &dataNewCustomer.PhoneNumber,
		DateOfBirth:   &dataNewCustomer.DateOfBirth,
		Gender:        dataNewCustomer.Gender,
		IdPremiumType: dataPremium.ID,
		ImageCustomer: dataNewCustomer.ImageUrl,
	}

	auth := &entity.Authentication{
		ID:            uuid.New(),
		IDCustomer:    &custId,
		Password:      "",
		Role:          entity.RoleCustomer,
		Email:         claims.Email,
		IsVerified:    true,
		LoginType:     entity.LoginWithOAuth,
		OAuthProvider: "google",
	}

	tx := c.db.Begin()

	if tx.Error != nil {
		tx.Rollback()
		helper.Logger("Failed start tx", BASE_PATH, err)
		return dto.AuthenticationResponse{}, errors.New(BASE_MESSAGE)
	}

	if err := c.customerRepo.Create(tx, customer); err != nil {
		tx.Rollback()
		helper.Logger("Failed create new customer", BASE_PATH, err)
		return dto.AuthenticationResponse{}, errors.New(BASE_MESSAGE)
	}

	if err := c.authRepo.Create(tx, auth); err != nil {
		tx.Rollback()
		helper.Logger("Failed create new auth", BASE_PATH, err)
		return dto.AuthenticationResponse{}, errors.New(BASE_MESSAGE)
	}
	expiresIn := 30 * 24 * time.Hour
	token, err := lib.GenerateToken(custId.String(), auth.Email, auth.Role, expiresIn)
	if err != nil {
		helper.Logger("Generate Token", "service/auth_service.go", err)
		return dto.AuthenticationResponse{}, errors.New("Terjadi kesalahan saat login! Coba lagi nanti.")
	}

	tx.Commit()
	return dto.AuthenticationResponse{
		AccessToken: token,
		User: dto.UserAuth{
			UserId: custId.String(),
			Email:  auth.Email,
			Role:   auth.Role,
		},
	}, nil
}

func (c *customerService) CredentialRegister(dataNewCustomer dto.CredentialCustomerRequest, ctx context.Context) (*dto.CredentialCustomerResponse, error) {
	const BASE_PATH = "service/customer_service.go"
	tx := c.db.Begin()
	if tx.Error != nil {
		log.Println("Error [START TRANSAKSI] [service/customer_service.go]:", tx.Error.Error())
		return &dto.CredentialCustomerResponse{}, errors.New(defaultRegisterErrMsg)
	}

	descriptionOTP := "Gunakan kode berikut untuk melanjutkan verifikasi akun kamu:"

	dataAuth, err := c.authRepo.FindOne("email = ?", dataNewCustomer.Email)
	if err == nil {
		if dataAuth.IsVerified {
			return &dto.CredentialCustomerResponse{}, errors.New("Email ini telah terdaftar dan terverifikasi!")
		}

		allowed, err := helper.AllowResendOTP(
			c.client,
			ctx,
			dataAuth.IDCustomer.String(),
			EXPIRED_OTP,        // FIX: cooldown = 3 menit (durasi OTP masih aktif)
			MAX_OTP_ATTEMPT,    // 5
			OTP_ATTEMPT_WINDOW, // FIX: window 16 menit (bukan EXPIRED_OTP lagi)
			OTP_BAN_DURATION,   // FIX: ban 15 menit
		)

		if err != nil {
			helper.Logger("Find Attemp", BASE_PATH, err)
			return &dto.CredentialCustomerResponse{}, errors.New(defaultRegisterErrMsg)
		}

		if !allowed {
			return &dto.CredentialCustomerResponse{}, errors.New("Mohon tunggu sebelum anda meminta OTP kembali.")
		}

		otp, err := c.issueOTP(ctx, *dataAuth.IDCustomer)
		if err != nil {
			return c.failRegister(tx, "ISSUE OTP", err)
		}

		dataCustomer, err := c.customerRepo.FindById(dataAuth.IDCustomer.String())
		if err != nil {
			return c.failRegister(tx, "GET DATA CUSTOMER", err)
		}

		err = c.sendOtp(ctx, *dataAuth.IDCustomer, otp, dataAuth.Email, dataCustomer.Name, descriptionOTP)
		if err != nil {
			return c.failRegister(tx, "Send OTP", err)
		}

		tx.Commit()
		return &dto.CredentialCustomerResponse{
			Id:    dataAuth.IDCustomer.String(),
			Email: dataAuth.Email,
		}, nil
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return c.failRegister(tx, "GET EMAIL", err)
	}

	dataPremium, err := c.premiumTypeRepo.FindOne("name = ?", "silver")
	if err != nil {
		helper.Logger("Find premium type", BASE_PATH, err)
		return &dto.CredentialCustomerResponse{}, errors.New("Terjadi kesalahan saat mencari data premium")
	}

	hashedPassword, err := helper.HashPassword(dataNewCustomer.Password)
	if err != nil {
		return c.failRegister(tx, "GENERATE HASH PASSWORD", err)
	}

	custId := uuid.New()
	customer := &entity.Customer{
		ID:            custId,
		Name:          dataNewCustomer.Name,
		PhoneNumber:   &dataNewCustomer.PhoneNumber,
		DateOfBirth:   &dataNewCustomer.DateOfBirth,
		Gender:        dataNewCustomer.Gender,
		IdPremiumType: dataPremium.ID,
		MemberPoints:  100,
		ImageCustomer: dataNewCustomer.ImageUrl,
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

	otp, err := c.issueOTP(ctx, *auth.IDCustomer)
	if err != nil {
		return c.failRegister(tx, "ISSUE OTP", err)
	}
	err = c.sendOtp(ctx, custId, otp, auth.Email, customer.Name, descriptionOTP)
	if err != nil {
		return c.failRegister(tx, "Send OTP", err)
	}

	tx.Commit()
	return &dto.CredentialCustomerResponse{
		Id:    custId.String(),
		Email: dataNewCustomer.Email,
	}, nil
}

func (c *customerService) VerifyOTP(ctx context.Context, dataOTPCust dto.VerifyCredentialRequest) (dto.VerifyOTPResponse, error) {
	const MESSAGE_ERROR = "Terjadi kesalahan saat verifikasi otp. Coba lagi nanti"
	const BASE_PATH = "service/customer_service.go"
	const RESET_TOKEN_EXPIRED = 10 * time.Minute

	parsedId, err := uuid.Parse(dataOTPCust.UserId)
	if err != nil {
		helper.Logger("Parsed string -> UUID", BASE_PATH, err)
		return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
	}

	dataAuth, err := c.authRepo.FindOne("id_customer = ?", parsedId)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.VerifyOTPResponse{}, errors.New("Data tidak ditemukan!")
		}
		helper.Logger("Find one auth repo", BASE_PATH, err)
		return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
	}

	keyOtpRedis := fmt.Sprintf("OTP:%v", dataOTPCust.UserId)
	keyTotalAttempt := fmt.Sprintf("otp_verify_attempt:%v", dataOTPCust.UserId)

	dataOtpResult := c.client.Get(ctx, keyOtpRedis)
	if dataOtpResult.Err() != nil {
		if errors.Is(dataOtpResult.Err(), redis.Nil) {
			if dataAuth.IsVerified {
				return dto.VerifyOTPResponse{}, errors.New("OTP sudah kedaluwarsa. Mohon kirim ulang OTP!")
			}
			return dto.VerifyOTPResponse{}, errors.New("OTP sudah kedaluwarsa. Mohon daftar ulang / kirim ulang OTP!")
		}
		helper.Logger("Find otp redis By user id", BASE_PATH, dataOtpResult.Err())
		return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
	}

	otp, err := dataOtpResult.Result()
	if err != nil {
		helper.Logger("Result otp from redis", BASE_PATH, err)
		return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
	}

	decrypted, err := helper.Decrypt(otp)
	if err != nil {
		helper.Logger("Decrypt OTP", BASE_PATH, err)
		return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
	}

	if decrypted != dataOTPCust.OTP {
		allowed, err := helper.AllowAttemp(c.client, ctx, keyTotalAttempt, 5, EXPIRED_OTP)
		if err != nil {
			helper.Logger("Increment attempt otp", BASE_PATH, err)
			return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
		}

		if !allowed {
			if err := c.client.Del(ctx, keyOtpRedis).Err(); err != nil {
				helper.Logger("Delete OTP, attempt count > 5", BASE_PATH, err)
				return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
			}
			return dto.VerifyOTPResponse{}, errors.New("Anda telah melakukan kesalahan 5 kali percobaan! Mohon untuk kirim ulang OTP!")
		}

		count, err := c.client.Get(ctx, keyTotalAttempt).Result()
		if err != nil {
			helper.Logger("Get total attempt otp", BASE_PATH, err)
			return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
		}
		totalAttempts, err := strconv.Atoi(count)
		if err != nil {
			helper.Logger("Failed convert string to int", BASE_PATH, err)
			return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
		}

		if totalAttempts == 5 {
			return dto.VerifyOTPResponse{}, errors.New("Anda telah melakukan percobaan sebanyak 5 kali. Coba lagi nanti!")
		}

		return dto.VerifyOTPResponse{}, fmt.Errorf("OTP tidak valid, silahkan coba lagi. Sisa percobaan %d kali", 5-totalAttempts)
	}

	// OTP Valid — bersihkan redis dulu, ini sama untuk kedua alur
	if err := c.client.Del(ctx, keyOtpRedis).Err(); err != nil {
		helper.Logger("Delete OTP while OTP is correct!", BASE_PATH, err)
		return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
	}
	if err := c.client.Del(ctx, keyTotalAttempt).Err(); err != nil {
		helper.Logger("Delete total attempt otp while OTP is correct!", BASE_PATH, err)
		return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
	}

	// ✅ FIX: alur FORGOT PASSWORD — akun sudah verified, jadi ini bukan proses register.
	// Terbitkan reset_token di sini (bukan di ForgotPassword), simpan ke Redis,
	// FE pakai token ini untuk step ResetPassword berikutnya.
	if dataAuth.IsVerified {
		resetToken, err := lib.GenerateToken(parsedId.String(), dataAuth.Email, dataAuth.Role, RESET_TOKEN_EXPIRED)
		if err != nil {
			helper.Logger("Generate reset token", BASE_PATH, err)
			return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
		}

		if err := c.client.Set(ctx, fmt.Sprintf("reset_token:%s", resetToken), dataAuth.Email, RESET_TOKEN_EXPIRED).Err(); err != nil {
			helper.Logger("Set reset token", BASE_PATH, err)
			return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
		}

		return dto.VerifyOTPResponse{ResetToken: resetToken}, nil
	}

	// alur REGISTER — belum verified, tandai verified sekarang
	tx := c.db.Begin()
	if tx.Error != nil {
		helper.Logger("Begin transaction", BASE_PATH, tx.Error)
		return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
	}

	if err := c.authRepo.UpdateVerifiedCredential(tx, parsedId, true); err != nil {
		tx.Rollback()
		helper.Logger("Update verified", BASE_PATH, err)
		return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
	}

	if err := tx.Commit().Error; err != nil {
		helper.Logger("Commit transaction", BASE_PATH, err)
		return dto.VerifyOTPResponse{}, errors.New(MESSAGE_ERROR)
	}

	return dto.VerifyOTPResponse{}, nil
}

func (c *customerService) ForgotPassword(ctx context.Context, dataForgotPassword dto.ForgotPasswordRequest) (dto.ForgotPassswordResponse, error) {
	const BASE_PATH = "service/customer_service.go"
	const BASE_MESSAGE = "Terjadi kesalahan saat reset password!"

	dataAuth, err := c.authRepo.FindOne("email = ?", dataForgotPassword.Email)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.ForgotPassswordResponse{}, errors.New("Email tidak terdaftar!")
		}
		helper.Logger("Find one data auth", BASE_PATH, err)
		return dto.ForgotPassswordResponse{}, errors.New(BASE_MESSAGE)
	}

	if !dataAuth.IsVerified {
		return dto.ForgotPassswordResponse{}, errors.New("Email belum verified! Tidak dapat reset password.")
	}

	if dataAuth.LoginType == entity.LoginWithOAuth {
		return dto.ForgotPassswordResponse{}, errors.New("Email Anda login dengan google! Tidak dapat reset password.")
	}

	allowed, err := helper.AllowAttemp(c.client, ctx, fmt.Sprintf("otp_resend_attempt:%v", dataAuth.Email), 1, EXPIRED_OTP)
	if err != nil {
		helper.Logger("Ask allowed req otp", BASE_PATH, err)
		return dto.ForgotPassswordResponse{}, errors.New(BASE_MESSAGE)
	}
	if !allowed {
		return dto.ForgotPassswordResponse{}, errors.New("Terlalu banyak percobaan, coba lagi nanti.")
	}

	otpPlain, err := c.issueOTP(ctx, *dataAuth.IDCustomer)
	if err != nil {
		helper.Logger("Create OTP", BASE_PATH, err)
		return dto.ForgotPassswordResponse{}, errors.New(BASE_MESSAGE)
	}

	userId := dataAuth.IDCustomer
	dataCustomer, err := c.customerRepo.FindById(userId.String())
	if err != nil {
		helper.Logger("Get customer by id", BASE_PATH, err)
		return dto.ForgotPassswordResponse{}, errors.New(BASE_MESSAGE)
	}

	description := "Gunakan kode berikut untuk mereset password anda."
	err = c.sendOtp(ctx, *userId, otpPlain, dataAuth.Email, dataCustomer.Name, description)
	if err != nil {
		helper.Logger("Send otp", BASE_PATH, err)
		return dto.ForgotPassswordResponse{}, errors.New(BASE_MESSAGE)
	}

	return dto.ForgotPassswordResponse{
		UserId: dataAuth.IDCustomer.String(),
	}, nil
}

func (c *customerService) GetProfile(claims *lib.CustomClaims) (dto.ProfileCustomerResponse, error) {
	dataCustomers, err := c.customerRepo.FindProfile(claims.UserId)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.ProfileCustomerResponse{}, errors.New("Akun anda tidak ditemukan!")
		}

		helper.Logger("Find data profile", "get profile", err)
		return dto.ProfileCustomerResponse{}, errors.New("Terdapat kesalahan saat mengambil data profile!")
	}

	dataPremium, err := c.premiumTypeRepo.FindOne("id = ?", dataCustomers.IdPremiumType)
	if err != nil {
		helper.Logger("Find premium type", "service/customer_service.go", err)
		return dto.ProfileCustomerResponse{}, errors.New("Terjadi kesalahan saat mencari data premium")
	}

	dataResult := dto.ProfileCustomerResponse{
		Id:            dataCustomers.ID,
		Name:          dataCustomers.Name,
		PhoneNumber:   *dataCustomers.PhoneNumber,
		DateOfBirth:   *dataCustomers.DateOfBirth,
		Gender:        dataCustomers.Gender,
		MemberPoints:  dataCustomers.MemberPoints,
		PremiumType:   dataPremium.Name,
		ImageUrl:      &dataCustomers.ImageCustomer,
		CreatedAt:     dataCustomers.CreatedAt,
		Role:          dataCustomers.Authentication.Role,
		Email:         dataCustomers.Authentication.Email,
		IsVerified:    dataCustomers.Authentication.IsVerified,
		LoginType:     dataCustomers.Authentication.LoginType,
		OauthProvider: dataCustomers.Authentication.OAuthProvider,
	}

	return dataResult, nil
}

func (c *customerService) sendOtp(ctx context.Context, userId uuid.UUID, otpPlain string, email string, name string, description string) error {
	key := fmt.Sprintf("OTP:%v", userId.String())

	minutes, err := helper.GetRemainingTime(c.client, ctx, key)
	if err != nil {
		return err
	}

	err = lib.SendEmailToUser(lib.EmailOptions{
		To:           []string{email},
		Subject:      "Kode OTP Barberstuff",
		TemplateName: "otp.html",
		TemplateData: map[string]interface{}{
			"AppName":       "Barberstuff",
			"Name":          name,
			"OTPCode":       otpPlain,
			"ExpiryMinutes": minutes,
			"Description":   description,
		},
	})

	return err
}

func (c *customerService) failRegister(tx *gorm.DB, label string, err error) (*dto.CredentialCustomerResponse, error) {
	tx.Rollback()
	helper.Logger(label, "service/customer_service.go", err)
	return &dto.CredentialCustomerResponse{}, errors.New(defaultRegisterErrMsg)
}

func (c *customerService) issueOTP(ctx context.Context, userId uuid.UUID) (string, error) {
	otpGenerated, err := helper.GenerateOTP()
	if err != nil {
		return "", err
	}

	otpEncrypted, err := helper.Encrypt(otpGenerated)
	if err != nil {
		return "", err
	}

	err = c.client.Set(ctx, fmt.Sprintf("OTP:%v", userId.String()), otpEncrypted, EXPIRED_OTP).Err()
	if err != nil {
		return "", err
	}

	return otpGenerated, nil
}
