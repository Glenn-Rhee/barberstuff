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

type BenefitHandler struct {
	service service.BenefitService
}

func NewBenefitHandler(sv service.BenefitService) *BenefitHandler {
	return &BenefitHandler{service: sv}
}

// CreateBenefit godoc
// @Summary      Membuat benefit baru
// @Description  Admin dapat membuat benefit baru dengan mengisi judul, deskripsi, URL gambar, dan status benefit.
// @Tags         Benefit
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.CreateBenefitReq true "Data benefit baru"
// @Success      200 {object} dto.SwaggerResponse "Berhasil membuat benefit baru"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal membuat benefit"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /benefit [post]
func (h *BenefitHandler) CreateBenefit(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleAdmin {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataBody dto.CreateBenefitReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.CrateBenefit(ctx.Request.Context(), dataBody)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil membuat benefit baru!",
		StatusCode: http.StatusOK,
	})
}

// GetBenefits godoc
// @Summary      Mendapatkan daftar benefit
// @Description  Admin dan customer dapat melihat daftar benefit dengan filter pencarian, status, pengurutan, dan pagination. Field status hanya disertakan dalam respons untuk admin, sedangkan customer tidak menerima field tersebut.
// @Tags         Benefit
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        q query string false "Pencarian berdasarkan judul atau deskripsi benefit"
// @Param        status query string false "Filter status benefit" Enums(visible, hide)
// @Param        sort_by query string false "Kolom pengurutan" Enums(title, status, created_at)
// @Param        page query int false "Nomor halaman" default(1) minimum(1)
// @Param        limit query int false "Jumlah data per halaman" default(20) minimum(1) maximum(50)
// @Param        order query string false "Urutan pengurutan" Enums(asc, desc)
// @Success      200 {object} dto.SwaggerResponse "Berhasil mengambil daftar benefit"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal mengambil data benefit"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /benefit [get]
func (h *BenefitHandler) GetBenefits(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleAdmin && claimsResult.Role != entity.RoleCustomer {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var reqParams dto.GetBenefitReq
	if err := ctx.ShouldBindQuery(&reqParams); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, meta, err := h.service.GetBenefits(reqParams, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[[]dto.GetBenefitRes]{
		Data:       result,
		Meta:       &meta,
		Message:    "Berhasil mengambil benefit!",
		StatusCode: http.StatusOK,
	})
}

// PatchBenefit godoc
// @Summary      Mengubah data benefit
// @Description  Admin dapat mengubah satu atau beberapa field benefit tanpa harus mengirim seluruh data.
// @Tags         Benefit
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID benefit"
// @Param        request body dto.PatchBenefitReq true "Data benefit yang akan diperbarui"
// @Success      200 {object} dto.SwaggerResponse "Berhasil mengubah benefit"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal mengubah benefit"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /benefit/{id} [patch]
func (h *BenefitHandler) PatchBenefit(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleAdmin {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataBody dto.PatchBenefitReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	idBenefit := ctx.Param("id")

	err := h.service.PatchBenefit(ctx.Request.Context(), dataBody, idBenefit)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil mengubah benefit!",
		StatusCode: http.StatusOK,
	})
}

// DeleteBenefit godoc
// @Summary      Menghapus benefit
// @Description  Admin menghapus benefit secara permanen dari database (hard delete).
// @Tags         Benefit
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID benefit"
// @Success      200 {object} dto.SwaggerResponse "Berhasil menghapus benefit"
// @Failure      400 {object} dto.SwaggerResponse "Gagal menghapus benefit"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /benefit/{id} [delete]
func (h *BenefitHandler) DeleteBenefit(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleAdmin {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	idBenefit := ctx.Param("id")

	err := h.service.DeleteBenefit(ctx.Request.Context(), idBenefit)

	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil menghapus benefit!",
		StatusCode: http.StatusOK,
	})
}
