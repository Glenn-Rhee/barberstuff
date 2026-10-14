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

// GetEmployee godoc
// @Summary      Daftar karyawan
// @Description  Mengambil daftar karyawan yang dapat difilter berdasarkan kata kunci, toko, jabatan, status karyawan, serta jabatan tertentu. Mendukung pagination serta pengurutan data. Dapat diakses oleh semua pengguna yang telah terauhtentikasi.
// @Tags         Employee
// @Produce      json
// @Security     BearerAuth
// @Param        q query string false "Kata kunci pencarian karyawan"
// @Param        id_store query string false "ID toko"
// @Param        id_position query string false "ID jabatan"
// @Param        status query string false "Status karyawan" Enums(active, inactive)
// @Param        page query int false "Halaman" minimum(1)
// @Param        limit query int false "Jumlah data per halaman" minimum(1) maximum(50)
// @Param        order query string false "Urutan data" Enums(asc, desc)
// @Success      200 {object} dto.SwaggerResponse{data=dto.GetEmployeeRes,meta=dto.ResponsePagination} "Berhasil mengambil data karyawan"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal mengambil data karyawan"
// @Router       /employee [get]
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

	var query dto.GetEmployeeReq
	if err := ctx.ShouldBindQuery(&query); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	data, meta, err := h.service.GetEmployees(query, claimsResult)
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

// PatchEmployee godoc
// @Summary      Mengubah data karyawan
// @Description  Admin dapat mengubah sebagian atau seluruh data karyawan berdasarkan ID, termasuk informasi pribadi, kontak, gaji, jabatan, toko, rekening bank, dan status karyawan. Nomor telepon harus menggunakan format +62xxxx atau 08xxxx. Hanya dapat diakses oleh admin.
// @Tags         Employee
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID Karyawan"
// @Param        request body dto.PatchEmployeeReq true "Data karyawan yang akan diubah"
// @Success      200 {object} dto.SwaggerResponse "Berhasil mengubah karyawan"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau nomor telepon tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal mengubah data karyawan"
// @Router       /employee/{id} [patch]
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

// DeleteEmployee godoc
// @Summary      Menghapus data karyawan
// @Description  Admin dapat menghapus data karyawan berdasarkan ID menggunakan mekanisme soft delete, sehingga data tidak dihapus secara permanen dari database. Hanya dapat diakses oleh admin.
// @Tags         Employee
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID Karyawan"
// @Success      200 {object} dto.SwaggerResponse "Berhasil menghapus karyawan"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal menghapus data karyawan"
// @Router       /employee/{id} [delete]
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

// Absent godoc
// @Summary      Mencatat absensi karyawan
// @Description  Mencatat absensi karyawan berdasarkan ID karyawan dan ID toko. Hanya dapat diakses oleh pengguna selain customer dan mitra.
// @Tags         Employee
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.CreateAbsentReq true "Data absensi karyawan"
// @Success      200 {object} dto.SwaggerResponse "Berhasil absen"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal mencatat absensi"
// @Router       /employee/absent [post]
func (h *EmployeeHandler) Absent(ctx *gin.Context) {
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

	if claimsResult.Role == entity.RoleCustomer || claimsResult.Role == entity.RoleMitra {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataBody dto.CreateAbsentReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if err := h.service.Absent(dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil absen!",
		StatusCode: http.StatusOK,
	})
}

// GetEmployeeAbsent godoc
// @Summary      Mengambil data absensi karyawan
// @Description  Mengambil data absensi karyawan pada hari ini berdasarkan ID toko. Hanya dapat diakses oleh pengguna selain customer dan mitra.
// @Tags         Employee
// @Produce      json
// @Security     BearerAuth
// @Param        id_store query string true "ID toko"
// @Success      200 {object} dto.SwaggerResponse{data=[]dto.GetEmployeeAbsentRes} "Berhasil mengambil data absensi"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal mengambil data absensi"
// @Router       /employee/absent [get]
func (h *EmployeeHandler) GetEmployeeAbsent(ctx *gin.Context) {
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

	if claimsResult.Role == entity.RoleCustomer || claimsResult.Role == entity.RoleMitra {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var query dto.GetEmployeeAbsentReq
	if err := ctx.ShouldBindQuery(&query); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.GetEmployeeAbsent(query)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[[]dto.GetEmployeeAbsentRes]{
		Data:       result,
		Message:    "Berhasil mengambil data absen!",
		StatusCode: http.StatusOK,
	})
}
