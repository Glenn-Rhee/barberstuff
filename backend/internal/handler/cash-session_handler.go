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

type CashSessionHandler struct {
	service service.CashSessionService
}

func NewCashSessionHandler(s service.CashSessionService) *CashSessionHandler {
	return &CashSessionHandler{service: s}
}

// Create godoc
// @Summary      Membuka cash session
// @Description  Membuka cash session baru dengan menentukan toko dan saldo awal. Endpoint ini hanya dapat digunakan oleh cashier.
// @Tags         Cash Session
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        body body dto.CreateCashSession true "Data cash session"
//
// @Success      200 {object} dto.SwaggerResponse "Berhasil membuka uang modal"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal membuka cash session"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /cash-sesssion [post]
func (h *CashSessionHandler) Create(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleCashier {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataBody dto.CreateCashSession
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.CreateCashSession(dataBody, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil membuka uang modal.",
		StatusCode: http.StatusOK,
	})
}
