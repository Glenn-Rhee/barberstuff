package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"errors"
	"time"

	"gorm.io/gorm"
)

type AuthenticationService interface {
	CredentialLogin(credentialData dto.CredentialLoginRequest) (*dto.CredentialLoginResponse, error)
}

type authenticationService struct {
	authenticationRepo repository.AuthenticationRepository
}

func NewAuthService(authRepo repository.AuthenticationRepository) AuthenticationService {
	return &authenticationService{authenticationRepo: authRepo}
}

func (a *authenticationService) CredentialLogin(credentialData dto.CredentialLoginRequest) (*dto.CredentialLoginResponse, error) {
	dataAuth, err := a.authenticationRepo.FindOne("email = ?", credentialData.Email)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &dto.CredentialLoginResponse{}, errors.New("Email tidak terdaftar.")
		}
		helper.Logger("Get data auth by email", "service/auth_service.go", err)
		return &dto.CredentialLoginResponse{}, errors.New("Terjadi kesalahan saat login! Coba lagi nanti.")
	}

	if !dataAuth.IsVerified {
		return &dto.CredentialLoginResponse{}, errors.New("Email belum verifikasi! Verifikasi terlebih dahulu.")
	}

	isPasswordMatch := helper.ComparePassword(dataAuth.Password, credentialData.Password)
	if !isPasswordMatch {
		return &dto.CredentialLoginResponse{}, errors.New("Password yang anda masukkan salah.")
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
		return &dto.CredentialLoginResponse{}, errors.New("Terjadi kesalahan saat login! Coba lagi nanti.")
	}

	return &dto.CredentialLoginResponse{
		AccessToken: token,
		ExpiresIn:   int(expiresIn),
		User: dto.UserAuth{
			UserId: userId,
			Email:  dataAuth.Email,
			Role:   dataAuth.Role,
		},
	}, nil
}
