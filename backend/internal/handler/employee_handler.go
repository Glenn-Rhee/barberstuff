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

type EmployeeHandler struct {
	service service.EmployeeService
}

func NewEmployeeHandler(service service.EmployeeService) *EmployeeHandler {
	return &EmployeeHandler{service: service}
}

// CreateEmployee godoc
//
// @Summary      Admin membuat karyawan baru
// @Description  Admin dapat membuat data karyawan baru dengan mengisi informasi pribadi, kontak, jabatan, toko, gaji, dokumen identitas, dan rekening bank. Nomor telepon harus menggunakan format +62xxxx atau 08xxxx. Hanya dapat diakses oleh admin.
//
// @Tags         Employee
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        request body dto.CreateEmployeeReq true "Data karyawan baru"
//
// @Success      200 {object} dto.SwaggerResponse "Berhasil membuat karyawan baru"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau nomor telepon tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal membuat karyawan"
//
// @Router       /employee [post]
func (h *EmployeeHandler) CreateEmployee(ctx *gin.Context) {
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

	var dataBody dto.CreateEmployeeReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if !helper.ValidatePhoneNumber(dataBody.PhoneNumber) {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "No telepon tidak valid, gunakan format +62xxxx atau 08xxxx",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if err := h.service.CreateEmployee(ctx.Request.Context(), dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil membuat karyawan baru!",
		StatusCode: http.StatusOK,
	})
}

func (h *EmployeeHandler) GetEmployee(ctx *gin.Context) {
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

	var query dto.GetEmployeeReq
	if err := ctx.ShouldBindQuery(&query); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	data, meta, err := h.service.GetEmployees(query)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.GetEmployeeRes]{
		Data:       data,
		Message:    "Berhasil ngambil data karyawan.",
		StatusCode: http.StatusOK,
		Meta:       &meta,
	})
}

func (h *EmployeeHandler) PatchEmployee(ctx *gin.Context) {
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

	var dataBody dto.PatchEmployeeReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if dataBody.PhoneNumber != nil && !helper.ValidatePhoneNumber(*dataBody.PhoneNumber) {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "No telepon tidak valid, gunakan format +62xxxx atau 08xxxx",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	idEmployee := ctx.Param("id")

	if err := h.service.PatchEmployee(ctx.Request.Context(), dataBody, idEmployee); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil mengubah karyawan!",
		StatusCode: http.StatusOK,
	})
}

func (h *EmployeeHandler) DeleteEmployee(ctx *gin.Context) {
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

	idEmployee := ctx.Param("id")

	if err := h.service.SoftDeleteEmployee(idEmployee); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil menghapus karyawan!",
		StatusCode: http.StatusOK,
	})
}
