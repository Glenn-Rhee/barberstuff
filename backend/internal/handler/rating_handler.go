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

type RatingHandler struct {
	service service.RatingService
}

func NewRatingHandler(s service.RatingService) *RatingHandler {
	return &RatingHandler{service: s}
}

// Create godoc
// @Summary      Membuat rating
// @Description  Membuat rating untuk booking. Customer wajib memberikan rating minimal pada salah satu objek (capster, staff, atau store), dan dapat memberikan rating pada lebih dari satu objek sekaligus. Hanya dapat diakses oleh customer
// @Tags         Rating
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.CreateRatingRequest true "Data rating"
// @Success      200 {object} dto.SwaggerResponse "Berhasil membuat rating baru!"
// @Failure      400 {object} dto.SwaggerResponse "Data rating tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal membuat rating"
// @Router       /rating [post]
func (h *RatingHandler) Create(ctx *gin.Context) {
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

	var req dto.CreateRatingRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if err := h.service.Create(req, claimsResult); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil membuat rating baru!",
		StatusCode: http.StatusOK,
	})
}
