package handler

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
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

// CreateAdmin godoc
// @Summary      Buat akun admin
// @Description  Membuat akun admin pertama kali menggunakan Secret-Key khusus pada header
// @Tags         Staff
// @Accept       json
// @Produce      json
// @Param        Secret-Key header string true "Secret key admin"
// @Param        request body dto.StaffRequest true "Data akun admin"
// @Success      200 {object} dto.SwaggerResponse "Berhasil membuat akun admin"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Secret key tidak valid"
// @Router       /auth/register/admin [post]
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
			StatusCode: http.StatusUnauthorized,
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

// CreateAccountStaff godoc
// @Summary      Tambah akun staff
// @Description  Membuat akun staff baru (cashier/mitra) pada toko tertentu. Hanya dapat diakses oleh admin
// @Tags         Staff
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        request body dto.CreateAccountStaffRequest true "Data akun staff baru"
// @Success      200 {object} dto.SwaggerResponse "Berhasil membuat akun staaff"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal membuat akun"
// @Router       /staff [post]
func (h *StaffHandler) CreateAccountStaff(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleAdmin {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var dataRequest dto.CreateAccountStaffRequest

	if err := ctx.ShouldBindJSON(&dataRequest); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if err := h.service.CreateAccout(dataRequest); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil membuat akun staaff",
		StatusCode: http.StatusOK,
	})
}

// GetAccountStaffes godoc
// @Summary      Daftar akun staff
// @Description  Mengambil daftar akun staff, dapat difilter berdasarkan toko, nama, atau email. Hanya dapat diakses oleh admin
// @Tags         Staff
// @Produce      json
// @Security     BearerAuth
// @Param        id_store query string false "ID toko"
// @Param        name query string false "Nama staff"
// @Param        email query string false "Email staff"
// @Success      200 {object} dto.SwaggerResponse{data=[]dto.StaffAccountsResponse} "Berhasil mengambil data akun staff!"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal mengambil data"
// @Router       /staff [get]
func (h *StaffHandler) GetAccountStaffes(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleAdmin {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	var query dto.QueryParamsAccountStaff
	if err := ctx.ShouldBindQuery(&query); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.GetAccounts(query)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[*[]dto.StaffAccountsResponse]{
		Data:       result,
		Message:    "Berhasil mengambil data akun staff!",
		StatusCode: http.StatusOK,
	})
}

// GetProfile godoc
// @Summary      Ambil profil staff
// @Description  Mengambil data profil staff/admin yang sedang login
// @Tags         Staff
// @Produce      json
// @Security     BearerAuth
// @Success      200 {object} dto.SwaggerResponse{data=dto.StaffAccountsResponse} "Berhasil mengambil data akun staff!"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Router       /profile/staff [get]
func (h *StaffHandler) GetProfile(ctx *gin.Context) {
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

	result, err := h.service.GetProfile(claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.StaffAccountsResponse]{
		Data:       result,
		Message:    "Berhasil mengambil data akun staff!",
		StatusCode: http.StatusOK,
	})
}

// UpdateAccountStaff godoc
// @Summary      Ubah akun staff
// @Description  Mengubah nama dan password akun staff berdasarkan ID
// @Tags         Staff
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID staff"
// @Param        request body dto.UpdateAccountStaffRequest true "Data staff yang diubah"
// @Success      200 {object} dto.SwaggerResponse "Berhasil mengubah data akun staff!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal mengubah data"
// @Router       /staff/{id} [patch]
func (h *StaffHandler) UpdateAccountStaff(ctx *gin.Context) {
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

	var dataRequest dto.UpdateAccountStaffRequest

	if err := ctx.ShouldBindJSON(&dataRequest); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}
	idStaff := ctx.Param("id")

	err := h.service.UpdateAccount(dataRequest, claimsResult, idStaff)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil mengubah data akun staff!",
		StatusCode: http.StatusOK,
	})
}

// DeleteAccountStaff godoc
// @Summary      Hapus akun staff
// @Description  Menghapus akun staff berdasarkan ID. Hanya dapat diakses oleh admin
// @Tags         Staff
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID staff"
// @Success      200 {object} dto.SwaggerResponse "Berhasil menghapus data akun staff!"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal menghapus data"
// @Router       /staff/{id} [delete]
func (h *StaffHandler) DeleteAccountStaff(ctx *gin.Context) {
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

	if claimsResult.Role != entity.RoleAdmin {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Anda tidak memiliki akses!",
			StatusCode: http.StatusUnauthorized,
		})
		return
	}

	idStaff := ctx.Param("id")

	err := h.service.DeleteAccount(idStaff, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil menghapus data akun staff!",
		StatusCode: http.StatusOK,
	})
}

// CreateBooking godoc
// @Summary      Membuat booking customer
// @Description  Membuat booking baru untuk customer yang dilakukan oleh cashier. Data booking meliputi toko, capster, layanan, jadwal booking, serta data customer.
// @Tags         Staff
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        body body dto.CreateCashireBookingRequest true "Data booking"
//
// @Success      200 {object} dto.SwaggerResponse "Berhasil membuat booking"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal membuat booking"
// @Router       /staff/booking [post]
func (h *StaffHandler) CreateBooking(ctx *gin.Context) {
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

	var dataBody dto.CreateCashireBookingRequest
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if dataBody.Customer.PhoneNumber != nil && !helper.ValidatePhoneNumber(*dataBody.Customer.PhoneNumber) {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "No telepon tidak valid, gunakan format +62xxxx atau 08xxxx",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.CreateBooking(claimsResult, dataBody)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil membuat booking!",
		StatusCode: http.StatusOK,
	})
}

// CheckinBooking godoc
// @Summary       Kasir checkin booking customer
// @Description   Kasir dapat melakukan perubahan status booking dari booked ke progress melalui routes ini. Hanya dapat diakses oleh kasir
// @Tags          Staff
// @Accept        json
// @Produce       json
// @Security      BearerAuth
//
// @Param         qr_code path string true "Qr Code"
//
// @Success       200 {object} dto.SwaggerResponse "Berhasil membuat booking"
// @Failure       400 {object} dto.SwaggerResponse "Parameter tidak valid"
// @Failure       401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Failure       406 {object} dto.SwaggerResponse "Gagal melakukan checkin booking"
// @Router        /staff/booking/checkin/{qr_code} [patch]
func (h *StaffHandler) CheckinBooking(ctx *gin.Context) {
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

	qrCode := ctx.Param("qr_code")

	err := h.service.CheckinBooking(qrCode, claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil checkin!",
		StatusCode: http.StatusOK,
	})
}

// AddBookingItem godoc
// @Summary      Menambahkan item layanan ke booking
// @Description  Menambahkan layanan ke dalam booking yang sudah ada. Endpoint ini hanya dapat digunakan oleh cashier.
// @Tags         Staff
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        body body dto.BookingItemReq true "Data booking item"
//
// @Success      200 {object} dto.SwaggerResponse "Berhasil menambahkan booking item"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal menambahkan booking item"
// @Router       /staff/booking/item [post]
func (h *StaffHandler) AddBookingItem(ctx *gin.Context) {
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

	var dataBody dto.BookingItemReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.AddItemBooking(dataBody)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil menambahkan booking item!",
		StatusCode: http.StatusOK,
	})
}

// DeleteBookingItem godoc
// @Summary      Menghapus item layanan dari booking
// @Description  Menghapus layanan dari booking yang sudah ada. Endpoint ini hanya dapat digunakan oleh cashier.
// @Tags         Staff
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        body body dto.BookingItemReq true "Data booking item"
//
// @Success      200 {object} dto.SwaggerResponse "Berhasil menghapus booking item"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal menghapus booking item"
// @Router       /staff/booking/item [delete]
func (h *StaffHandler) DeleteBookingItem(ctx *gin.Context) {
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

	var dataBody dto.BookingItemReq
	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.DeleteItemBooking(dataBody)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil menghapus booking item!",
		StatusCode: http.StatusOK,
	})
}

// UpdateBooking godoc
//
// @Summary      Kasir membatalkan booking customer
// @Description  Kasir dapat membatalkan booking customer dengan menambahkan catatan (notes) melalui routes ini. Hanya dapat diakses oleh kasir.
//
// @Tags         Staff
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        id_booking path string true "ID Booking"
// @Param        request body dto.UpdateBookingReq true "Data pembatalan booking"
//
// @Success      200 {object} dto.SwaggerResponse "Berhasil membatalkan booking"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal membatalkan booking"
//
// @Router       /staff/booking/{id_booking} [patch]
func (h *StaffHandler) UpdateBooking(ctx *gin.Context) {
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

	idBooking := ctx.Param("id")
	var dataBody dto.UpdateBookingReq

	if err := ctx.ShouldBindJSON(&dataBody); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.UpdateBooking(claimsResult, dataBody, idBooking)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Data:       nil,
		Message:    "Berhasil membatalkan booking!",
		StatusCode: http.StatusOK,
	})
}
