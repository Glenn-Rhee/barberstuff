package handler

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/service"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

type StaffHandler struct {
	service service.StaffService
}

func NewStaffHandler(service service.StaffService) *StaffHandler {
	return &StaffHandler{service: service}
}

func (h *StaffHandler) CreateAdmin(ctx *gin.Context) {
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}

	key := ctx.Request.Header.Get("Secret-Key")
	if key != os.Getenv("SECRET_KEY_ADMIN") {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Opps! Anda tidak memiliki akses.",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	var dataRequest dto.StaffRequest

	if err := ctx.ShouldBindJSON(&dataRequest); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.CreateAdmin(dataRequest)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil membuat akun admin",
		StatusCode: http.StatusOK,
	})
}
