package helper

import (
	"barberstuff_backend/internal/dto"

	"github.com/gin-gonic/gin"
)

func NewErrorResponse[T any](ctx *gin.Context, dataResponse dto.ResponseApi[T]) {
	ctx.JSON(dataResponse.StatusCode, dto.ResponseApi[any]{
		Data:       nil,
		Message:    dataResponse.Message,
		StatusCode: dataResponse.StatusCode,
		Status:     dto.StatusFailed,
	})
}

func NewSuccessResponse[T any](ctx *gin.Context, dataResponse dto.ResponseApi[T]) {
	ctx.JSON(dataResponse.StatusCode, dto.ResponseApi[T]{
		Data:       dataResponse.Data,
		Message:    dataResponse.Message,
		StatusCode: dataResponse.StatusCode,
		Status:     dto.StatusSuccess,
	})
}
