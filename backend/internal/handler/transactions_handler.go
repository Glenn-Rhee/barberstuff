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

type TransactionsHandler struct {
	service service.TransactionsService
}

func NewTransactionsHandler(s service.TransactionsService) *TransactionsHandler {
	return &TransactionsHandler{service: s}
}

// CreateTransaction godoc
// @Summary      Membuat transaksi
// @Description  Membuat transaksi baru yang dilakukan oleh cashier. Jika transaction_type bernilai income, maka id_booking dan payment_type wajib diisi. Jika transaction_type bernilai outcome, maka title dan amount wajib diisi.
// @Tags         Transactions
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        body body dto.CreateTransactionReq true "Data transaksi"
//
// @Success      201 {object} dto.SwaggerResponse "Berhasil membuat transaksi"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal membuat transaksi"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /transactions [post]
func (h *TransactionsHandler) CreateTransaction(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleCashier {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataBody dto.CreateTransactionReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.CreateTransaction(dataBody)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil membuat transaksi",
		StatusCode: http.StatusCreated,
	})
}

// VoidTransaction godoc
//
// @Summary      Kasir melakukan void transaksi
// @Description  Kasir dapat melakukan void transaksi dengan menyertakan ID transaksi dan deskripsi alasan void. Hanya dapat diakses oleh kasir.
//
// @Tags         Transactions
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        request body dto.VoidTransactionReq true "Data void transaksi"
//
// @Success      201 {object} dto.SwaggerResponse "Berhasil void transaksi"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal melakukan void transaksi"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
//
// @Router       /transactions/void [patch]
func (h *TransactionsHandler) VoidTransaction(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleCashier {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataBody dto.VoidTransactionReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.VoidTransaction(claimsResult, dataBody)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil void transaksi",
		StatusCode: http.StatusCreated,
	})
}
