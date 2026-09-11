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

type BookingHandler struct {
	service service.BookingService
}

func NewBookingHandler(s service.BookingService) *BookingHandler {
	return &BookingHandler{service: s}
}

// LockBooking godoc
// @Summary      Kunci slot booking
// @Description  Mengunci slot booking (capster, toko, dan tanggal tertentu) agar tidak bisa dipesan customer lain untuk sementara waktu. Hanya dapat diakses oleh customer
// @Tags         Booking
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.LockBookingRequest true "Data booking yang akan dikunci"
// @Success      200 {object} dto.SwaggerResponse "Berhasil Lock booking!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid / gagal lock booking"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Router       /booking/lock [post]
func (h *BookingHandler) LockBooking(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleCustomer {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataBody dto.LockBookingRequest
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.LockBooking(dataBody, claimsResult, ctx.Request.Context())
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil Lock booking!",
		StatusCode: http.StatusOK,
	})
}

// CreateBooking godoc
// @Summary      Buat booking baru
// @Description  Membuat booking baru untuk service, capster, dan toko tertentu, mengembalikan detail booking beserta QR code. Hanya dapat diakses oleh customer
// @Tags         Booking
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.CreateBookingRequest true "Data booking yang akan dibuat"
// @Success      200 {object} dto.SwaggerResponse{data=dto.CreateBookingResponse} "Berhasil membuat booking!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid / gagal membuat booking"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Router       /booking [post]
func (h *BookingHandler) CreateBooking(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleCustomer {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataBody dto.CreateBookingRequest
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.CreateBooking(ctx.Request.Context(), claimsResult, dataBody)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.CreateBookingResponse]{
		Data:       result,
		Message:    "Berhasil Lock booking!",
		StatusCode: http.StatusOK,
	})
}

// GetDataBookingStore godoc
// @Summary      Cek ketersediaan slot booking toko
// @Description  Mengambil data slot waktu, ketersediaan, dan daftar capster yang tersedia pada toko dan tanggal tertentu
// @Tags         Booking
// @Produce      json
// @Security     BearerAuth
// @Param        date     query string true "Tanggal booking (format RFC3339, contoh: 2026-09-11T00:00:00Z)"
// @Param        id_store query string true "ID toko"
// @Success      200 {object} dto.SwaggerResponse{data=dto.GetBookingStoreResponse} "Berhasil mengambil data booking toko!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid / gagal mengambil data"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Router       /booking/store [GET]
func (h *BookingHandler) GetDataBookingStore(ctx *gin.Context) {
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

	var reqParams dto.GetBookingStoreRequest
	if err := ctx.ShouldBindQuery(&reqParams); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.GetBookingStore(ctx.Request.Context(), claimsResult, reqParams)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.GetBookingStoreResponse]{
		Data:       result,
		Message:    "Berhasil mengambil data booking toko!",
		StatusCode: http.StatusOK,
	})
}

func (h *BookingHandler) DeleteLockBooking(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleCustomer {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var reqParams dto.DeleteLockBookingRequest
	if err := ctx.ShouldBindQuery(&reqParams); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.DeleteLockBooking(ctx.Request.Context(), claimsResult, reqParams)
	if err  != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message: err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil delete lock booking!",
		StatusCode: http.StatusOK,
	})
}
