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

type PromoHandler struct {
	service service.PromoService
}

func NewPromoHandler(serv service.PromoService) *PromoHandler {
	return &PromoHandler{service: serv}
}

// CreatePromo godoc
// @Summary      Admin membuat promo baru
// @Description  Admin dapat membuat promo baru dengan mengisi judul, status, deskripsi, jenis diskon, nilai diskon, batas penggunaan per pelanggan, tanggal mulai, tanggal kedaluwarsa, dan URL gambar promo.
// @Tags         Promo
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.CreatePromoReq true "Data promo baru"
// @Success      200 {object} dto.SwaggerResponse "Berhasil membuat promo baru"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal membuat promo"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /promo [post]
func (h *PromoHandler) CreatePromo(ctx *gin.Context) {
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

	var dataBody dto.CreatePromoReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.CreatePromo(ctx.Request.Context(), dataBody)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil membuat promo baru!",
		StatusCode: http.StatusOK,
	})
}

// GetPromo godoc
// @Summary      Mendapatkan daftar promo
// @Description  Mengambil daftar promo dengan filter pencarian, status, dan jenis diskon, serta mendukung pagination dan pengurutan. Jika parameter sort_by tidak dikirim, data diurutkan berdasarkan jumlah klaim terbanyak. Default page adalah 1 dan limit adalah 20.
// @Tags         Promo
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        q query string false "Pencarian berdasarkan judul promo"
// @Param        status query string false "Filter status promo" Enums(visible, hide)
// @Param        discount_type query string false "Filter jenis diskon" Enums(percentage, fixed)
// @Param        sort_by query string false "Kolom pengurutan, default akan diurutkan dari promo yang sering diclaim" Enums(name, created_at, discount_value)
// @Param        page query int false "Nomor halaman" default(1) minimum(1)
// @Param        limit query int false "Jumlah data per halaman" default(20) minimum(1) maximum(50)
// @Param        order query string false "Urutan pengurutan" Enums(asc, desc)
// @Success      200 {object} dto.SwaggerResponse "Berhasil mengambil data promo"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal mengambil data promo"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /promo [get]
func (h *PromoHandler) GetPromo(ctx *gin.Context) {
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

	var reqParams dto.GetPromoReq
	if err := ctx.ShouldBindQuery(&reqParams); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, meta, err := h.service.GetPromo(reqParams, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[[]dto.GetPromoRes]{
		Data:       result,
		Meta:       &meta,
		Message:    "Berhasil mengambil data promo!",
		StatusCode: http.StatusOK,
	})
}

// PatchPromo godoc
// @Summary      Mengubah data promo
// @Description  Admin dapat mengubah satu atau beberapa field promo tanpa harus mengirim seluruh data. Minimal satu field harus dikirim untuk diperbarui.
// @Tags         Promo
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID promo"
// @Param        request body dto.PatchPromoReq true "Data promo yang akan diperbarui"
// @Success      200 {object} dto.SwaggerResponse "Berhasil mengubah data promo"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal mengubah data promo"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /promo/{id} [patch]
func (h *PromoHandler) PatchPromo(ctx *gin.Context) {
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

	var dataBody dto.PatchPromoReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	idPromo := ctx.Param("id")

	err := h.service.PatchPromo(ctx.Request.Context(), dataBody, idPromo)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil mengubah promo baru!",
		StatusCode: http.StatusOK,
	})
}

// DeletePromo godoc
// @Summary      Menghapus promo
// @Description  Admin menghapus promo secara soft delete, sehingga data tidak dihapus secara permanen dari database.
// @Tags         Promo
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID promo"
// @Success      200 {object} dto.SwaggerResponse "Berhasil menghapus promo"
// @Failure      400 {object} dto.SwaggerResponse "Gagal menghapus promo"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /promo/{id} [delete]
func (h *PromoHandler) DeletePromo(ctx *gin.Context) {
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

	idPromo := ctx.Param("id")

	err := h.service.DeletePromo(idPromo)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil menghapus promo!",
		StatusCode: http.StatusOK,
	})
}

// ClaimedPromo godoc
// @Summary      Klaim promo
// @Description  Customer yang telah login dapat mengklaim promo berdasarkan ID promo.
// @Tags         Promo
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id_promo path string true "ID promo yang akan diklaim"
// @Success      200 {object} dto.SwaggerResponse "Berhasil claim promo"
// @Failure      400 {object} dto.SwaggerResponse "Gagal melakukan klaim promo"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /promo/claim/{id_promo} [post]
func (h *PromoHandler) ClaimedPromo(ctx *gin.Context) {
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

	idPromo := ctx.Param("id")

	err := h.service.ClaimPromo(idPromo, claimsResult)

	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil claim promo!",
		StatusCode: http.StatusOK,
	})
}

func (h *PromoHandler) GetClaimPromo(ctx *gin.Context) {
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

	var reqParams dto.GetPromoClaimReq
	if err := ctx.ShouldBindQuery(&reqParams); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, meta, err := h.service.GetClaimPromo(reqParams, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[[]dto.GetPromoClaimRes]{
		Data:       result,
		Meta:       &meta,
		Message:    "Berhasil mengambil data promo!",
		StatusCode: http.StatusOK,
	})
}
