package dto

import "barberstuff_backend/internal/entity"

type UpsertDeviceTokenReq struct {
	FcmToken   string                         `json:"fcm_token" binding:"required"`
	AppVersion *string                        `json:"app_version" binding:"omitempty,max=20"`
	Platform   entity.PlatformDeviceTokenEnum `json:"platform" binding:"required,oneof=android"`
}
