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
