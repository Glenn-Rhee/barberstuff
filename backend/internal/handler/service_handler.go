package handler

import (
	"barberstuff_backend/internal/dto"
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
// @Param		 id_store 	query string true "Id Toko"
// @Param		 type 		query string true "Service Type" Enums(service, package)
// @Param        name    	query string false "Nama service"
// @Param        page    	query int    false "Page"
// @Param        limit  	query int    false "Limit"
// @Param        sortBy  	query string false "Sort By"  Enums(name, created_at) default(name)
// @Param        orderBy 	query string false "Order By" Enums(asc, desc)        default(asc)
// @Success      200 {object} dto.SwaggerResponse{data=[]dto.GetServiceResponse,meta=dto.ResponsePagination} "Succes get data services!"
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
		Message:    "Succes get data stores!",
		StatusCode: http.StatusOK,
		Meta:       &paginationData,
	})
}
