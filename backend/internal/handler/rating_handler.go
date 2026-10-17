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

// GetRating godoc
// @Summary      Mendapatkan daftar rating
// @Description  Admin dan customer dapat melihat daftar rating dengan filter ID target, pencarian, rentang skor rating, pengurutan, dan pagination. Skor rating tidak dapat mengirim salah satunya, kirim keduanya atau tidak sama sekali. Apabila ingin filter rating untuk score 5 saja, maka rating_min_score=5&rating_max_score=5
// @Tags         Rating
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id_target query string false "ID target rating"
// @Param        q query string false "Kata kunci pencarian"
// @Param        rating_min_score query int false "Skor rating minimum (1-5)" minimum(1) maximum(5)
// @Param        rating_max_score query int false "Skor rating maksimum (1-5)" minimum(1) maximum(5)
// @Param        sort_by query string false "Kolom pengurutan" Enums(score, created_at)
// @Param        page query int false "Nomor halaman" default(1) minimum(1)
// @Param        limit query int false "Jumlah data per halaman" default(20) minimum(1) maximum(50)
// @Param        order query string false "Urutan pengurutan" Enums(asc, desc)
// @Success      200 {object} dto.SwaggerResponse "Berhasil mengambil daftar rating"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Failure      424 {object} dto.SwaggerResponse "Gagal mengambil data rating"
// @Router       /rating [get]
func (h *RatingHandler) GetRating(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleCustomer && claimsResult.Role != entity.RoleAdmin {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var query dto.GetRatingReq
	if err := ctx.ShouldBindQuery(&query); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, paginationData, err := h.service.GetRatings(query)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusFailedDependency,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[[]dto.GetRatingRes]{
		Data:       result,
		Message:    "Succes get data stores!",
		StatusCode: http.StatusOK,
		Meta:       &paginationData,
	})
}
