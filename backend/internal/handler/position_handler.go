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

type PositionHandler struct {
	service service.PositionService
}

func NewPositionHandler(service service.PositionService) *PositionHandler {
	return &PositionHandler{service: service}
}

// CreatePosition godoc
//
// @Summary      Admin membuat jabatan baru
// @Description  Admin dapat membuat jabatan baru dengan mengisi nama jabatan dan gaji pokok. Hanya dapat diakses oleh admin.
//
// @Tags         Position
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        request body dto.CreatePositionReq true "Data jabatan baru"
//
// @Success      200 {object} dto.SwaggerResponse "Berhasil membuat jabatan baru"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal membuat jabatan"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
//
// @Router       /position [post]
func (h *PositionHandler) CreatePosition(ctx *gin.Context) {
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

	var dataBody dto.CreatePositionReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.CreatePosition(dataBody)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil membuat jabatan baru!",
		StatusCode: http.StatusOK,
	})
}

// GetPosition godoc
//
// @Summary      Admin mengambil daftar jabatan
// @Description  Admin dapat mengambil daftar jabatan dengan pencarian berdasarkan query (q). Hanya dapat diakses oleh admin.
//
// @Tags         Position
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        q query string false "Kata kunci pencarian jabatan"
//
// @Success      200 {object} dto.SwaggerResponse{data=[]dto.GetPositionRes} "Berhasil mengambil jabatan"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal mengambil jabatan"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
//
// @Router       /position [get]
func (h *PositionHandler) GetPosition(ctx *gin.Context) {
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

	var reqParams dto.GetPositionReq
	if err := ctx.ShouldBindQuery(&reqParams); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	data, err := h.service.GetPositions(reqParams)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[[]dto.GetPositionRes]{
		Data:       data,
		Message:    "Berhasil mengambil jabatan!",
		StatusCode: http.StatusOK,
	})
}

// UpdatePosition godoc
//
// @Summary      Admin mengubah data jabatan
// @Description  Admin dapat mengubah nama jabatan dan/atau gaji pokok berdasarkan ID jabatan. Hanya dapat diakses oleh admin.
//
// @Tags         Position
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        id path string true "ID Jabatan"
// @Param        request body dto.UpdatePositionReq true "Data jabatan yang akan diubah"
//
// @Success      200 {object} dto.SwaggerResponse "Berhasil mengubah jabatan"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal mengubah jabatan"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
//
// @Router       /position/{id} [patch]
func (h *PositionHandler) UpdatePosition(ctx *gin.Context) {
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

	var dataBody dto.UpdatePositionReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	idPosition := ctx.Param("id")

	err := h.service.UpdatePosition(dataBody, idPosition)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil mengubah jabatan.",
		StatusCode: http.StatusOK,
	})
}

// DeletePosition godoc
//
// @Summary      Admin menghapus jabatan
// @Description  Admin dapat menghapus jabatan berdasarkan ID melalui mekanisme soft delete, sehingga data jabatan tidak dihapus secara permanen dari database. Hanya dapat diakses oleh admin.
//
// @Tags         Position
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        id path string true "ID Jabatan"
//
// @Success      200 {object} dto.SwaggerResponse "Berhasil menghapus jabatan"
// @Failure      400 {object} dto.SwaggerResponse "Gagal menghapus jabatan"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
//
// @Router       /position/{id} [delete]
func (h *PositionHandler) DeletePosition(ctx *gin.Context) {
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

	idPosition := ctx.Param("id")
	err := h.service.DeletePosition(idPosition)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil menghapus jabatan.",
		StatusCode: http.StatusOK,
	})
}
