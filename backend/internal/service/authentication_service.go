package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"errors"
	"fmt"
	"time"

	"gorm.io/gorm"
)

type AuthenticationService interface {
	CredentialLogin(credentialData dto.CredentialLoginRequest) (*dto.AuthenticationResponse, error)
	AuthProvider(dataAuthProvider dto.AuthProviderRequest) (dto.AuthProviderResponse, error)
}

type authenticationService struct {
	authenticationRepo repository.AuthenticationRepository
}

func NewAuthService(authRepo repository.AuthenticationRepository) AuthenticationService {
	return &authenticationService{authenticationRepo: authRepo}
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

func (a *authenticationService) AuthProvider(dataAuthProvider dto.AuthProviderRequest) (dto.AuthProviderResponse, error) {
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
			expiresIn := 1 * 24 * time.Hour

			tempToken, err := lib.GenerateToken(fmt.Sprintf("USR-%d", timestamp), claims.Email, entity.RoleCustomer, expiresIn)
			if err != nil {
				helper.Logger("Generate Token temp", BASE_PATH, err)
				return dto.AuthProviderResponse{}, errors.New(BASE_MESSAGE)
			}

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
