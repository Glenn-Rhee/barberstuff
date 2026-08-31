package middleware

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"net/http"

	"github.com/gin-gonic/gin"
)

func AuthMiddleware(ctx *gin.Context) {
	authHeader := ctx.Request.Header.Get("Authorization")
	token, err := lib.ExtractTokenFromHeader(authHeader)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusForbidden,
		})
		ctx.Abort()
		return
	}

	claims, err := lib.ParseToken(token)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusUnauthorized,
		})
		ctx.Abort()
		return
	}

	ctx.Set("claims", claims)
	ctx.Next()
}
