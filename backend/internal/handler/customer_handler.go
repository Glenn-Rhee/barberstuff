package handler

import (
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/service"
	"net/http"

	"github.com/gin-gonic/gin"
)

type CustomerHandler struct {
	service service.CustomerService
}

func NewCustomerHandler(service service.CustomerService) *CustomerHandler {
	return &CustomerHandler{service: service}
}

func (h *CustomerHandler) CreateCustomer(ctx *gin.Context) {
	ctx.JSON(http.StatusOK, helper.NewSuccessResponse(200, "Success", "Cihuy"))
}
