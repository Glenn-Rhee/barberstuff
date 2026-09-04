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
	"time"

	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
)

type AuthenticationService interface {
	CredentialLogin(credentialData dto.CredentialLoginRequest) (*dto.AuthenticationResponse, error)
	AuthProvider(dataAuthProvider dto.AuthProviderRequest, ctx context.Context) (dto.AuthProviderResponse, error)
	ResetPassword(ctx context.Context, req dto.ResetPasswordRequest) error
	RefreshToken(token string) (dto.RefreshTokenBody, error)
}

type authenticationService struct {
	authenticationRepo repository.AuthenticationRepository
	client             *redis.Client
}

func NewAuthService(authRepo repository.AuthenticationRepository, client *redis.Client) AuthenticationService {
	return &authenticationService{authenticationRepo: authRepo, client: client}
}

func (a *authenticationService) CredentialLogin(credentialData dto.CredentialLoginRequest) (*dto.AuthenticationResponse, error) {
	dataAuth, err := a.authenticationRepo.FindOne("email = ?", credentialData.Email)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &dto.AuthenticationResponse{}, errors.New("Email tidak terdaftar.")
		}
		helper.Logger("Get data auth by email", "service/auth_service.go", err)
		return &dto.AuthenticationResponse{}, errors.New("Terjadi kesalahan saat login! Coba lagi nanti.")
	}

	if !dataAuth.IsVerified {
		return &dto.AuthenticationResponse{}, errors.New("Email belum verifikasi! Verifikasi terlebih dahulu.")
	}

	isPasswordMatch := helper.ComparePassword(dataAuth.Password, credentialData.Password)
	if !isPasswordMatch {
		return &dto.AuthenticationResponse{}, errors.New("Password yang anda masukkan salah.")
	}

	var userId string
	if dataAuth.Role == entity.RoleCustomer {
		userId = dataAuth.IDCustomer.String()
	} else {
		userId = dataAuth.IDStaff.String()
	}

	expiresIn := 30 * 24 * time.Hour

	token, err := lib.GenerateToken(userId, dataAuth.Email, dataAuth.Role, expiresIn)
	if err != nil {
		helper.Logger("Generate Token", "service/auth_service.go", err)
		return &dto.AuthenticationResponse{}, errors.New("Terjadi kesalahan saat login! Coba lagi nanti.")
	}

	return &dto.AuthenticationResponse{
		AccessToken: token,
		User: dto.UserAuth{
			UserId: userId,
			Email:  dataAuth.Email,
			Role:   dataAuth.Role,
		},
	}, nil
}

func (a *authenticationService) AuthProvider(dataAuthProvider dto.AuthProviderRequest, ctx context.Context) (dto.AuthProviderResponse, error) {
	const BASE_PATH = "service/customer_service.go"
	const BASE_MESSAGE = "Terjadi kesalahan saat authentikasi"
	if dataAuthProvider.Provider != dto.Google {
		return dto.AuthProviderResponse{}, errors.New("Provider tidak tersedia!")
	}

	claims, err := lib.VerifyIdTokenGoogle(dataAuthProvider.IdToken)
	if err != nil {
		helper.Logger("Verify token", BASE_PATH, err)
		return dto.AuthProviderResponse{}, errors.New(BASE_MESSAGE)
	}

	if !claims.EmailVerified {
		return dto.AuthProviderResponse{}, errors.New("Email anda belum terverifikasi oleh Google. Silahkan verifikasi terlebih dahulu")
	}

	dataAuth, err := a.authenticationRepo.FindOne("email = ?", claims.Email)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			timestamp := time.Now().UnixMilli()
			expiresIn := 15 * time.Minute

			allowed, err := helper.AllowAttemp(a.client, ctx, fmt.Sprintf("temp_token:%v", claims.Email), 3, expiresIn)

			if err != nil {
				helper.Logger("Ask allowed req temp token", BASE_PATH, err)
				return dto.AuthProviderResponse{}, errors.New(BASE_MESSAGE)
			}

			if !allowed {
				return dto.AuthProviderResponse{}, errors.New("Terlalu banyak percobaan, coba lagi nanti.")
			}

			tempToken, err := lib.GenerateToken(fmt.Sprintf("USR-%d", timestamp), claims.Email, entity.RoleCustomer, expiresIn)
			if err != nil {
				helper.Logger("Generate Token temp", BASE_PATH, err)
				return dto.AuthProviderResponse{}, errors.New(BASE_MESSAGE)
			}

			a.client.Set(ctx, tempToken, claims.Email, expiresIn)

			return dto.AuthProviderResponse{
				Email:     claims.Email,
				Name:      claims.Name,
				Status:    dto.NEED_COMPLETE_PROFILE,
				TempToken: tempToken,
			}, nil
		}

		helper.Logger("Find one data auth", BASE_PATH, err)
		return dto.AuthProviderResponse{}, errors.New(BASE_MESSAGE)
	}

	expiresIn := 30 * 24 * time.Hour
	token, err := lib.GenerateToken(dataAuth.IDCustomer.String(), dataAuth.Email, dataAuth.Role, expiresIn)
	if err != nil {
		helper.Logger("Generate token", BASE_PATH, err)
		return dto.AuthProviderResponse{}, errors.New(BASE_MESSAGE)
	}

	return dto.AuthProviderResponse{
		Email:       claims.Email,
		Name:        claims.Name,
		Status:      dto.SUCCESS,
		AccessToken: token,
	}, nil
}

func (c *authenticationService) ResetPassword(ctx context.Context, req dto.ResetPasswordRequest) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat reset password, coba lagi nanti!"
	const BASE_PATH = "service/auth_service.go"
	key := fmt.Sprintf("reset_token:%s", req.ResetToken)
	email, err := c.client.GetDel(ctx, key).Result()
	if errors.Is(err, redis.Nil) {
		return errors.New("Token tidak valid atau sudah kedaluwarsa.")
	}
	if err != nil {
		helper.Logger("Get and delete key", BASE_PATH, err)
		return errors.New(BASE_MESSAGE)
	}

	hashed, err := helper.HashPassword(req.NewPassword)
	if err != nil {
		helper.Logger("Hash Password", BASE_PATH, err)
		return errors.New(BASE_MESSAGE)
	}

	return c.authenticationRepo.ResetPassword(hashed, email)
}

func (c *authenticationService) RefreshToken(token string) (dto.RefreshTokenBody, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat data admin"
	expiresIn := 30 * 24 * time.Hour
	newToken, err := lib.RefreshToken(token, expiresIn)

	if err != nil {
		if errors.Is(err, lib.ErrTokenInvalid) {
			return dto.RefreshTokenBody{}, err
		}
		helper.Logger("Refresh token", "Refresh token at authentication service", err)
		return dto.RefreshTokenBody{}, errors.New(BASE_MESSAGE)
	}

	return dto.RefreshTokenBody{
		RefreshToken: newToken,
	}, nil
}
