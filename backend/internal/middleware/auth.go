package middleware

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func AuthMiddleware(authRepo repository.AuthenticationRepository, staffRepo repository.StaffRepository, customerRepo repository.CustomerRepository) gin.HandlerFunc {
	return func(ctx *gin.Context) {
		const BASE_MESSAGE = "Terdapat kesalahan dalam proses validasi!"

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

		if claims.Role == entity.RoleCustomer {
			_, err = customerRepo.FindById(claims.UserId)
		} else {
			_, err = staffRepo.FindOne("id = ?", claims.UserId)
		}

		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
					Message:    "Akun tidak ditemukan atau telah dihapus!",
					StatusCode: http.StatusForbidden,
				})
				ctx.Abort()
				return
			}

			helper.Logger("Find data user", "middleware", err)
			helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
				Message:    BASE_MESSAGE,
				StatusCode: http.StatusForbidden,
			})
			ctx.Abort()
			return
		}

		ctx.Set("claims", claims)
		ctx.Next()
	}
}
