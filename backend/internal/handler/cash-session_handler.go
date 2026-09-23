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

type CashSessionHandler struct {
	service service.CashSessionService
}

func NewCashSessionHandler(s service.CashSessionService) *CashSessionHandler {
	return &CashSessionHandler{service: s}
}

// Create godoc
// @Summary      Membuka cash session
// @Description  Membuka cash session baru dengan menentukan toko dan saldo awal. Endpoint ini hanya dapat digunakan oleh cashier.
// @Tags         Cash Session
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        body body dto.CreateCashSession true "Data cash session"
//
// @Success      200 {object} dto.SwaggerResponse{data=dto.CreateCashSessionResponse} "Berhasil membuka uang modal"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal membuka cash session"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /cash-sessions [post]
func (h *CashSessionHandler) Create(ctx *gin.Context) {
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

	var dataBody dto.CreateCashSession
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.CreateCashSession(dataBody, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.CreateCashSessionResponse]{
		Data:       result,
		Message:    "Berhasil membuka uang modal.",
		StatusCode: http.StatusCreated,
	})
}

// GetToday godoc
// @Summary      Mengambil cash session hari ini
// @Description  Mengambil data cash session yang sedang berjalan pada hari ini, berdasarkan toko milik kasir. Endpoint ini hanya dapat digunakan oleh kasir.
// @Tags         Cash Session
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Success      201 {object} dto.SwaggerResponse{data=dto.GetCashSessionResponse} "Berhasil mengambil data"
// @Failure      400 {object} dto.SwaggerResponse "Gagal mengambil data cash session"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /cash-sessions [get]
func (h *CashSessionHandler) GetToday(ctx *gin.Context) {
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

	result, err := h.service.GetToday(claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.GetCashSessionResponse]{
		Data:       result,
		Message:    "Berhasil mengambil data.",
		StatusCode: http.StatusOK,
	})
}

// CloseCashSession godoc
// @Summary      Menutup cash session
// @Description  Menutup cash session dan mencatat jumlah uang aktual yang tersedia. Endpoint ini hanya dapat digunakan oleh cashier. Response akan memberikan selisih antara saldo yang seharusnya tersedia dengan jumlah aktual serta status selisih tersebut.
// @Tags         Cash Session
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        body body dto.CloseCashSessionRequest true "Data penutupan cash session"
//
// @Success      200 {object} dto.SwaggerResponse{data=dto.CloseCashSessionResponse} "Berhasil menutup pembukuan"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau gagal menutup cash session"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /cash-sessions [patch]
func (h *CashSessionHandler) CloseCashSession(ctx *gin.Context) {
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

	var dataBody dto.CloseCashSessionRequest
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.CloseCashSession(dataBody, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.CloseCashSessionResponse]{
		Data:       result,
		Message:    "Berhasil Menutup pembukuan.",
		StatusCode: http.StatusOK,
	})
}

func (h *CashSessionHandler) GetHistory(ctx *gin.Context) {
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

	if claimsResult.Role == entity.RoleCustomer {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var query dto.HistoryCashSessionReq

	if err := ctx.ShouldBindQuery(&query); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, pagination, err := h.service.GetHistory(claimsResult, query)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[[]dto.HistoryCashSessionRes]{
		Data:       result,
		Message:    "Success get history",
		StatusCode: http.StatusOK,
		Meta:       &pagination,
	})
}
