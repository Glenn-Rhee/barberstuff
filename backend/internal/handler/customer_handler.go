package handler

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/service"
	"net/http"

	"github.com/gin-gonic/gin"
)

type CustomerHandler struct {
	service service.CustomerService
}

func NewCustomerHandler(service service.CustomerService) *CustomerHandler {
	return &CustomerHandler{service: service}
}

func (h *CustomerHandler) OauthRegister(ctx *gin.Context) {
	var dataNewCustomer dto.OauthCustomerRequest

	if err := ctx.ShouldBindJSON(&dataNewCustomer); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if !helper.ValidatePhoneNumber(dataNewCustomer.PhoneNumber) {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "No telepon tidak valid, gunakan format +62xxxx atau 08xxxx",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.OauthRegister(dataNewCustomer)

	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Message:    "Berhasil registrasi dengan google!",
		Data:       nil,
		StatusCode: http.StatusOK,
	})
}

func (h *CustomerHandler) CredentialRegister(ctx *gin.Context) {
	var dataNewCustomer dto.CredentialCustomerRequest
	if err := ctx.ShouldBindJSON(&dataNewCustomer); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if !helper.ValidatePhoneNumber(dataNewCustomer.PhoneNumber) {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "No telepon tidak valid, gunakan format +62xxxx atau 08xxxx",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.CredentialRegister(dataNewCustomer)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.CredentialCustomerResponse]{
		Message:    "OTP telah dikirim ke email Anda. Silakan periksa kotak masuk atau spam.",
		Data:       *result,
		StatusCode: http.StatusOK,
	})
}

func (h *CustomerHandler) VerifyCredential(ctx *gin.Context) {
	var dataOtpCustomer dto.VerifyCredentialRequest

	if err := ctx.ShouldBindJSON(&dataOtpCustomer); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if !helper.ValidateOTP(dataOtpCustomer.OTP) {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Hanya masukkan OTP berupa angka diantara 0-9",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.VerifyOTP(dataOtpCustomer)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Message:    "Berhasil verifikasi akun! Silahkan login.",
		Data:       nil,
		StatusCode: http.StatusOK,
	})
}
