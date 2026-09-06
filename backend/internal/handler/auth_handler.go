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

// CredentialLogin godoc
// @Summary      Login menggunakan email & password
// @Description  Melakukan autentikasi menggunakan kombinasi email dan password, mengembalikan access token
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        request body dto.CredentialLoginRequest true "Kredensial login"
// @Success      200 {object} dto.SwaggerResponse{data=dto.AuthenticationResponse} "Login Berhasil!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Router       /auth/login/credential [post]
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

// AuthProvider godoc
// @Summary      Login/registrasi melalui OAuth provider
// @Description  Melakukan autentikasi menggunakan provider pihak ketiga seperti Google
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        request body dto.AuthProviderRequest true "Data ID token dan provider"
// @Success      200 {object} dto.SwaggerResponse{data=dto.AuthProviderResponse} "Login Berhasil!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Router       /auth/provider [post]
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

// ResetPassword godoc
// @Summary      Reset password
// @Description  Mengganti password menggunakan reset token yang telah diverifikasi
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        request body dto.ResetPasswordRequest true "Reset token dan password baru"
// @Success      200 {object} dto.SwaggerResponse "Password berhasil direset!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Router       /auth/reset [post]
func (h *AuthHandler) ResetPassword(ctx *gin.Context) {
	var dataResetPassword dto.ResetPasswordRequest
	if err := ctx.ShouldBindJSON(&dataResetPassword); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.ResetPassword(ctx.Request.Context(), dataResetPassword)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Password berhasil direset!",
		StatusCode: http.StatusOK,
	})
}

// RefreshToken godoc
// @Summary      Perbarui access token
// @Description  Membuat access token baru menggunakan refresh token yang masih valid
// @Tags         Auth
// @Accept       json
// @Produce      json
// @Param        request body dto.RefreshTokenBody true "Refresh token"
// @Success      200 {object} dto.SwaggerResponse{data=dto.RefreshTokenBody} "Berhasil"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Router       /auth/refresh-token [post]
func (h *AuthHandler) RefreshToken(ctx *gin.Context) {
	var dataRequst dto.RefreshTokenBody
	if err := ctx.ShouldBindJSON(&dataRequst); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.RefreshToken(dataRequst.RefreshToken)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.RefreshTokenBody]{
		Data:       result,
		Message:    "Berhasil",
		StatusCode: http.StatusOK,
	})
}