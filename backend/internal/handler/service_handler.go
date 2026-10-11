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

type ServiceHandler struct {
	service service.ServiceService
}

func NewServiceHandler(service service.ServiceService) *ServiceHandler {
	return &ServiceHandler{service: service}
}

// GetServices godoc
// @Summary      Mengambil semua data service
// @Description  Mengambil semua data service serta dapat melakukan filter serta pagination
// @Tags         Service
// @Produce      json
// @Security     BearerAuth
// @Param		 id_store 	query string false "Id Toko"
// @Param		 type 		query string false "Service Type" Enums(service, package, product)
// @Param        name    	query string false "Nama service"
// @Param        page    	query int    false "Page"
// @Param        limit  	query int    false "Limit"
// @Param        sortBy  	query string false "Sort By"  Enums(name, created_at) default(name)
// @Param        orderBy 	query string false "Order By" Enums(asc, desc)        default(asc)
// @Success      200 {object} dto.SwaggerResponse{data=[]dto.GetServiceResponse,meta=dto.ResponsePagination} "Succes get data products!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Failure      424 {object} dto.SwaggerResponse "Gagal mengambil data"
// @Router       /service [get]
func (h *ServiceHandler) GetServices(ctx *gin.Context) {
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

	var query dto.QueryParamsService
	if err := ctx.ShouldBindQuery(&query); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, paginationData, err := h.service.GetServices(query, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusFailedDependency,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[[]dto.GetServiceResponse]{
		Data:       result,
		Message:    "Succes get data products!",
		StatusCode: http.StatusOK,
		Meta:       &paginationData,
	})
}

// Create godoc
// @Summary      Tambah service/package baru
// @Description  Membuat data service/package pada suato toko tertentu. Hanya dapat diakses oleh admin
// @Tags         Service
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.CreateServiceRequest true "Data service baru"
// @Success      200 {object} dto.SwaggerResponse "Berhasil membuat service baru!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Router       /service [post]
func (h *ServiceHandler) CreateService(ctx *gin.Context) {
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
			Message:    "Anda tidak memiliki akses",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataBody dto.CreateServiceRequest
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.CreateService(ctx.Request.Context(), dataBody)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})

		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Message:    "Succes create new service",
		StatusCode: http.StatusCreated,
	})
}

// UpdateService godoc
// @Summary      Update data service/package
// @Description  Mengupdate data service/package berdasarkan ID. Field yang ingin diubah dapat dikirim secara parsial, sehingga tidak semua field wajib dikirim.
// @Tags         Service
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        id path string true "ID service/package" format(uuid)
// @Param        body body dto.UpdateServiceRequest true "Data service/package yang ingin diupdate"
//
// @Success      200 {object} dto.SwaggerResponse "Berhasil mengupdate service/package"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid atau gagal mengupdate service/package"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /service/{id} [patch]
func (h *ServiceHandler) UpdateService(ctx *gin.Context) {
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
			Message:    "Anda tidak memiliki akses",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataBody dto.UpdateServiceRequest
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	id := ctx.Param("id")

	err := h.service.UpdateService(ctx.Request.Context(), dataBody, id)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})

		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Message:    "Succes update data service",
		StatusCode: http.StatusCreated,
	})
}

// DeleteService godoc
// @Summary      Hapus service/package
// @Description  Menghapus data service/package berdasarkan ID.
// @Tags         Service
// @Produce      json
// @Security     BearerAuth
//
// @Param        id path string true "ID service" format(uuid)
//
// @Success      200 {object} dto.SwaggerResponse "Berhasil menghapus service"
// @Failure      400 {object} dto.SwaggerResponse "Gagal menghapus service"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /service/{id} [delete]
func (h *ServiceHandler) DeleteService(ctx *gin.Context) {
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
			Message:    "Anda tidak memiliki akses",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	id := ctx.Param("id")

	err := h.service.DeleteService(id)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})

		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Message:    "Succes update data service",
		StatusCode: http.StatusCreated,
	})
}
