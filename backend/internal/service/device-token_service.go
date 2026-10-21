package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"errors"
	"runtime"
	"time"

	"github.com/google/uuid"
)

type DeviceTokenService interface {
	UpsertDeviceToken(req dto.UpsertDeviceTokenReq, claims *lib.CustomClaims) error
}

type deviceTokenService struct {
	deviceTokenRepo repository.DeviceTokenRepository
}

func NewDeviceTokenService(dtr repository.DeviceTokenRepository) DeviceTokenService {
	return &deviceTokenService{deviceTokenRepo: dtr}
}

func (s *deviceTokenService) UpsertDeviceToken(req dto.UpsertDeviceTokenReq, claims *lib.CustomClaims) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat menyimpan data perangkat!"
	_, filePath, _, _ := runtime.Caller(0)

	idUser, err := uuid.Parse(claims.UserId)
	if err != nil {
		return errors.New("Data tidak valid. Mohon registrasi ulang.")
	}

	if err := helper.ValidateFCMToken(req.FcmToken); err != nil {
		return err
	}

	d := entity.DeviceToken{
		ID:         uuid.New(),
		IdUser:     idUser,
		FcmToken:   req.FcmToken,
		Platform:   req.Platform,
		AppVersion: req.AppVersion,
		IsActive:   true,
		LastSeenAt: time.Now(),
	}

	err = s.deviceTokenRepo.Upsert(&d)
	if err != nil {
		helper.Logger("upsert device token", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}
