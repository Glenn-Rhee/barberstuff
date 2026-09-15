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

type StoreHandler struct {
	service service.StoreService
}

func NewStoreHandler(service service.StoreService) *StoreHandler {
	return &StoreHandler{service: service}
}

// CreateNewStore godoc
// @Summary      Tambah toko cabang baru
// @Description  Membuat data toko cabang baru. Hanya dapat diakses oleh admin
// @Tags         Store
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.NewStoreRequest true "Data toko baru"
// @Success      200 {object} dto.SwaggerResponse "Berhasil membuat toko cabang baru!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Router       /store [post]
func (h *StoreHandler) CreateNewStore(ctx *gin.Context) {
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

	var dataBody dto.NewStoreRequest
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

	err := h.service.CreateNewStore(dataBody)

	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil membuat toko cabang baru!",
		StatusCode: http.StatusOK,
	})
}

// GetStores godoc
// @Summary      Daftar toko cabang
// @Description  Mengambil daftar toko cabang, dapat difilter berdasarkan nama. Hanya dapat diakses oleh admin dan customer
// @Tags         Store
// @Produce      json
// @Security     BearerAuth
// @Param        name query string false "Nama toko"
// @Param		 page query int false "Page"
// @Param		 limit query int false "Limit"
// @Param		 sortBy query string false "Sort By" Enums(name, created_at) default(name)
// @Param        orderBy query string false "Order By" Enums(asc, desc) default(asc)
// @Success      200 {object} dto.SwaggerResponse{data=[]dto.StoreData,meta=dto.ResponsePagination} "Succes get data stores!"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Failure      424 {object} dto.SwaggerResponse "Gagal mengambil data"
// @Router       /store [get]
func (h *StoreHandler) GetStores(ctx *gin.Context) {
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

	var query dto.QueryParamsStores

	if err := ctx.ShouldBindQuery(&query); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, paginationData, err := h.service.GetStores(query, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusFailedDependency,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[[]dto.StoreData]{
		Data:       result,
		Message:    "Succes get data stores!",
		StatusCode: http.StatusOK,
		Meta:       &paginationData,
	})
}

// GetStore godoc
// @Summary      Detail toko cabang
// @Description  Mengambil detail satu toko cabang berdasarkan ID
// @Tags         Store
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID toko"
// @Success      200 {object} dto.SwaggerResponse{data=dto.StoreData} "Succes get data store!"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Failure      424 {object} dto.SwaggerResponse "Gagal mengambil data"
// @Router       /store/{id} [get]
func (h *StoreHandler) GetStore(ctx *gin.Context) {
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

	if claimsResult.Role == entity.RoleCashier {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	idStore := ctx.Param("id")
	result, err := h.service.GetStore(*claimsResult, idStore)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusFailedDependency,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.StoreData]{
		Data:       result,
		Message:    "Succes get data store!",
		StatusCode: http.StatusOK,
	})
}

// UpdateStore godoc
// @Summary      Ubah toko cabang
// @Description  Mengubah data toko cabang berdasarkan ID. Hanya dapat diakses oleh admin dan Field yang ingin diubah dapat dikirim secara parsial, sehingga tidak semua field wajib dikirim.
// @Tags         Store
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID toko"
// @Param        request body dto.UpdateStoreRequest true "Data toko yang diubah"
// @Success      200 {object} dto.SwaggerResponse "Berhasil mengubah toko cabang!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Router       /store/{id} [patch]
func (h *StoreHandler) UpdateStore(ctx *gin.Context) {
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

	var dataBody dto.UpdateStoreRequest

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

	idStore := ctx.Param("id")

	err := h.service.UpdateStore(dataBody, idStore)

	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil mengubah toko cabang!",
		StatusCode: http.StatusOK,
	})
}

// DeleteStore godoc
// @Summary      Hapus toko cabang
// @Description  Menghapus data toko cabang berdasarkan ID. Hanya dapat diakses oleh admin
// @Tags         Store
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID toko"
// @Success      200 {object} dto.SwaggerResponse "Berhasil menghapus toko cabang!"
// @Failure      400 {object} dto.SwaggerResponse "Gagal menghapus data"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Router       /store/{id} [delete]
func (h *StoreHandler) DeleteStore(ctx *gin.Context) {
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

	idStore := ctx.Param("id")
	err := h.service.DeleteStore(idStore)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil menghapus toko cabang!",
		StatusCode: http.StatusOK,
	})
}
