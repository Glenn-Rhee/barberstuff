package handler

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/service"
	"net/http"

	"github.com/gin-gonic/gin"
)

type DeviceTokenHandler struct {
	service service.DeviceTokenService
}

func NewDeviceTokenHandler(service service.DeviceTokenService) *DeviceTokenHandler {
	return &DeviceTokenHandler{service: service}
}

// UpsertDevice godoc
// @Summary      Simpan data perangkat
// @Description  Menyimpan atau memperbarui FCM token perangkat customer untuk kebutuhan push notification. Hanya dapat diakses oleh customer.
// @Tags         Device Token
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.UpsertDeviceTokenReq true "Data perangkat customer"
// @Success      200 {object} dto.SwaggerResponse "Berhasil menyimpan data perangkat!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid atau gagal menyimpan data perangkat"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Router       /devices [post]
func (h *DeviceTokenHandler) UpsertDevice(ctx *gin.Context) {
	claims, exist := ctx.Get("claims")
	if !exist {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	claimsResult, ok := claims.(*lib.CustomClaims)
	if !ok {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Gagal membaca data!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	if claimsResult.Role != entity.RoleCustomer {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataBody dto.UpsertDeviceTokenReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.UpsertDeviceToken(dataBody, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil menyimpan data perangkat!",
		StatusCode: http.StatusOK,
	})
}

// Deactivate godoc
// @Summary      Nonaktifkan perangkat
// @Description  Menonaktifkan perangkat customer berdasarkan FCM token. Hanya dapat diakses oleh customer.
// @Tags         Device Token
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.DeactivateDeviceReq true "FCM token perangkat yang akan dinonaktifkan"
// @Success      200 {object} dto.SwaggerResponse "Berhasil menghapus data perangkat!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid atau gagal menonaktifkan perangkat"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Router       /devices [patch]
func (h *DeviceTokenHandler) Deactivate(ctx *gin.Context) {
	claims, exist := ctx.Get("claims")
	if !exist {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	claimsResult, ok := claims.(*lib.CustomClaims)
	if !ok {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Gagal membaca data!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	if claimsResult.Role != entity.RoleCustomer {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataBody dto.DeactivateDeviceReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.Deactivate(dataBody, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil menghapus data perangkat!",
		StatusCode: http.StatusOK,
	})
}
