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

type NotificationHandler struct {
	service service.NotificationService
}

func NewNotifHandler(service service.NotificationService) *NotificationHandler {
	return &NotificationHandler{service: service}
}

// GetNotifications godoc
// @Summary      Mendapatkan daftar notifikasi
// @Description  Customer dapat mengambil daftar notifikasi miliknya dengan filter pencarian, rentang waktu, dan pagination. Notifikasi ditampilkan dari yang terbaru ke terlama secara default.
// @Tags         Notifications
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        q query string false "Kata kunci pencarian notifikasi"
// @Param        before_at query string false "Filter notifikasi sebelum waktu tertentu (RFC3339)" Format(date-time)
// @Param        after_at query string false "Filter notifikasi setelah waktu tertentu (RFC3339)" Format(date-time)
// @Param        page query int false "Nomor halaman" default(1) minimum(1)
// @Param        limit query int false "Jumlah data per halaman" default(20) minimum(1) maximum(50)
// @Param        order query string false "Urutan pengurutan berdasarkan waktu" Enums(asc, desc) default(desc)
// @Success      200 {object} dto.SwaggerResponse{data=dto.GetNotificationRes,meta=dto.ResponsePagination} "Berhasil mengambil daftar notifikasi"
// @Failure      400 {object} dto.SwaggerResponse "Parameter query tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Failure      424 {object} dto.SwaggerResponse "Gagal mengambil data notifikasi"
// @Router       /notifications [get]
func (h *NotificationHandler) GetNotifications(ctx *gin.Context) {
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

	var query dto.GetNotificationReq
	if err := ctx.ShouldBindQuery(&query); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, paginationData, err := h.service.GetNotifications(query, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusFailedDependency,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.GetNotificationRes]{
		Data:       result,
		Message:    "Succes get data notif!",
		StatusCode: http.StatusOK,
		Meta:       &paginationData,
	})
}

// MarkAsRead godoc
// @Summary      Menandai notifikasi sebagai sudah dibaca
// @Description  Customer dapat menandai notifikasi tertentu sebagai sudah dibaca dengan mengirim ids_notif (minimal 1 dan maksimal 100 ID), atau menandai semua notifikasi sebagai sudah dibaca dengan mengirim all bernilai true. Hanya salah satu dari ids_notif atau all yang boleh dikirim dalam satu request.
// @Tags         Notifications
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.MarkReadNotifReq true "ID notifikasi atau penanda untuk membaca semua notifikasi"
// @Success      200 {object} dto.SwaggerResponse "Berhasil menandai notifikasi sebagai sudah dibaca"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid atau kedua opsi dikirim sekaligus"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /notifications/mark-as-read [patch]
func (h *NotificationHandler) MarkAsRead(ctx *gin.Context) {
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

	var dataBody dto.MarkReadNotifReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.MarkRead(dataBody, claimsResult)

	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil menandai baca notif!",
		StatusCode: http.StatusOK,
	})
}
