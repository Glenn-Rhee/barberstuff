package helper
import "barberstuff_backend/internal/dto"

func NewErrorResponse(statusCode int, message string) dto.ResponseApi[any] {
	return dto.ResponseApi[any]{
		Data:       nil,
		Message:    message,
		StatusCode: statusCode,
	}
}

func NewSuccessResponse[T any](statusCode int, message string, data T) dto.ResponseApi[T] {
	return dto.ResponseApi[T]{
		Data:       data,
		Message:    message,
		StatusCode: statusCode,
	}
}
