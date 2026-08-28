package handler

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/service"
	"net/http"

	"github.com/gin-gonic/gin"
)

type AuthHandler struct {
	service service.AuthenticationService
}

func NewAuthHandler(service service.AuthenticationService) *AuthHandler {
	return &AuthHandler{service: service}
}

func (h *AuthHandler) CredentialLogin(ctx *gin.Context) {
	var dataCredential dto.CredentialLoginRequest

	if err := ctx.ShouldBindJSON(&dataCredential); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	resultData, err := h.service.CredentialLogin(dataCredential)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       resultData,
		Message:    "Login Berhasil!",
		StatusCode: http.StatusOK,
	})
}

func (h *AuthHandler) AuthProvider(ctx *gin.Context) {
	var dataAuthProvider dto.AuthProviderRequest

	if err := ctx.ShouldBindJSON(&dataAuthProvider); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.AuthProvider(dataAuthProvider, ctx.Request.Context())
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.AuthProviderResponse]{
		Data:       result,
		Message:    "Login Berhasil!",
		StatusCode: http.StatusOK,
	})
}