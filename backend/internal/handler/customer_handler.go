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

type CustomerHandler struct {
	service service.CustomerService
}

func NewCustomerHandler(service service.CustomerService) *CustomerHandler {
	return &CustomerHandler{service: service}
}

// OauthRegister godoc
// @Summary      Registrasi customer melalui OAuth
// @Description  Melengkapi data diri customer baru yang mendaftar melalui provider OAuth (Google, dll)
// @Tags         Customer
// @Accept       json
// @Produce      json
// @Param        request body dto.OauthCustomerRequest true "Data registrasi OAuth"
// @Success      200 {object} dto.SwaggerResponse{data=dto.AuthenticationResponse} "Berhasil registrasi dengan google!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Router       /auth/register/oauth [post]
func (h *CustomerHandler) OauthRegister(ctx *gin.Context) {
	var dataNewCustomer dto.OauthCustomerRequest

	if err := ctx.ShouldBindJSON(&dataNewCustomer); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if !helper.ValidatePhoneNumber(dataNewCustomer.PhoneNumber) {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "No telepon tidak valid, gunakan format +62xxxx atau 08xxxx",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if !helper.ValidateMinAge(dataNewCustomer.DateOfBirth) {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Minimal usia untuk mendaftar adalah 6 bulan!",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.OauthRegister(dataNewCustomer, ctx.Request.Context())

	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.AuthenticationResponse]{
		Message:    "Berhasil registrasi dengan google!",
		Data:       result,
		StatusCode: http.StatusOK,
	})
}

// CredentialRegister godoc
// @Summary      Registrasi customer baru
// @Description  Mendaftarkan customer baru menggunakan email dan password, OTP akan dikirim ke email
// @Tags         Customer
// @Accept       json
// @Produce      json
// @Param        request body dto.CredentialCustomerRequest true "Data registrasi customer"
// @Success      200 {object} dto.SwaggerResponse{data=dto.CredentialCustomerResponse} "OTP telah dikirim ke email Anda"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Failure      406 {object} dto.SwaggerResponse "Registrasi gagal"
// @Router       /auth/register/credential [post]
func (h *CustomerHandler) CredentialRegister(ctx *gin.Context) {
	var dataNewCustomer dto.CredentialCustomerRequest
	if err := ctx.ShouldBindJSON(&dataNewCustomer); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if !helper.ValidatePhoneNumber(dataNewCustomer.PhoneNumber) {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "No telepon tidak valid, gunakan format +62xxxx atau 08xxxx",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if !helper.ValidateMinAge(dataNewCustomer.DateOfBirth) {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Minimal usia untuk mendaftar adalah 6 bulan!",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.CredentialRegister(dataNewCustomer, ctx.Request.Context())
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.CredentialCustomerResponse]{
		Message:    "OTP telah dikirim ke email Anda. Silakan periksa kotak masuk atau spam.",
		Data:       *result,
		StatusCode: http.StatusOK,
	})
}

// VerifyCredential godoc
// @Summary      Verifikasi OTP registrasi
// @Description  Memverifikasi kode OTP yang dikirim saat proses registrasi customer
// @Tags         Customer
// @Accept       json
// @Produce      json
// @Param        request body dto.VerifyCredentialRequest true "User ID dan kode OTP"
// @Success      200 {object} dto.SwaggerResponse{data=dto.VerifyOTPResponse} "Berhasil verifikasi!"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid"
// @Failure      406 {object} dto.SwaggerResponse "Verifikasi gagal"
// @Router       /auth/verify-credential [post]
func (h *CustomerHandler) VerifyCredential(ctx *gin.Context) {
	var dataOtpCustomer dto.VerifyCredentialRequest

	if err := ctx.ShouldBindJSON(&dataOtpCustomer); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if !helper.ValidateOTP(dataOtpCustomer.OTP) {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "Hanya masukkan OTP berupa angka diantara 0-9",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.VerifyOTP(ctx.Request.Context(), dataOtpCustomer)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.VerifyOTPResponse]{
		Message:    "Berhasil verifikasi!",
		Data:       result,
		StatusCode: http.StatusOK,
	})
}

// ForgotPassword godoc
// @Summary      Lupa password
// @Description  Mengirimkan kode OTP ke email untuk proses reset password
// @Tags         Customer
// @Accept       json
// @Produce      json
// @Param        request body dto.ForgotPasswordRequest true "Email customer"
// @Success      200 {object} dto.SwaggerResponse{data=dto.ForgotPassswordResponse} "Berhasil kirim otp"
// @Failure      406 {object} dto.SwaggerResponse "Gagal mengirim otp"
// @Router       /auth/forgot [post]
func (h *CustomerHandler) ForgotPassword(ctx *gin.Context) {
	var dataResetPassword dto.ForgotPasswordRequest

	if err := ctx.ShouldBindJSON(&dataResetPassword); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, err := h.service.ForgotPassword(ctx.Request.Context(), dataResetPassword)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.ForgotPassswordResponse]{
		Message:    "Berhasil kirim otp",
		Data:       result,
		StatusCode: http.StatusOK,
	})
}

// GetProfile godoc
// @Summary      Ambil profil customer
// @Description  Mengambil data profil customer yang sedang login
// @Tags         Customer
// @Produce      json
// @Security     BearerAuth
// @Success      200 {object} dto.SwaggerResponse{data=dto.ProfileCustomerResponse} "Berhasil mengambil data!"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Router       /profile/customer [get]
func (h *CustomerHandler) GetProfile(ctx *gin.Context) {
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

	result, err := h.service.GetProfile(claimsResult)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.ProfileCustomerResponse]{
		Message:    "Berhasil mengambil data!",
		Data:       result,
		StatusCode: http.StatusOK,
	})
}

// UpdateProfile godoc
// @Summary      Update data customer
// @Description  Mengupdate data customer. Field yang ingin diubah dapat dikirim secara parsial, sehingga tidak semua field wajib dikirim. Hanya customer yang dapat mengakses.
// @Tags         Customer
// @Accept       json
// @Produce      json
// @Security     BearerAuth
//
// @Param        body body dto.UpdateProfileRequest true "Data customer yang ingin diupdate"
//
// @Success      200 {object} dto.SwaggerResponse "Berhasil mengupdate customer"
// @Failure      400 {object} dto.SwaggerResponse "Data tidak valid atau gagal mengupdate customer"
// @Failure      401 {object} dto.SwaggerResponse "Anda tidak memiliki akses"
// @Router       /profile/customer [patch]
func (h *CustomerHandler) UpdateProfile(ctx *gin.Context) {
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

	var dataRequest dto.UpdateProfileRequest
	if err := ctx.ShouldBindJSON(&dataRequest); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	if dataRequest.PhoneNumber != nil && !helper.ValidatePhoneNumber(*dataRequest.PhoneNumber) {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    "No telepon tidak valid, gunakan format +62xxxx atau 08xxxx",
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	err := h.service.UpdateProfile(ctx.Request.Context(), claimsResult, dataRequest)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[any]{
		Message:    "Berhasil mengupdate profile data!",
		Data:       nil,
		StatusCode: http.StatusOK,
	})
}

// FindCustomers godoc
// @Summary      Daftar customer
// @Description  Mengambil daftar customer beserta informasi kunjungan, layanan favorit, capster favorit, dan KPI customer. Hanya dapat diakses oleh admin, kasir, maupun mitra
// @Tags         Customer
// @Produce      json
// @Security     BearerAuth
// @Param        q query string false "Pencarian berdasarkan nama, phone_number, id, atau email pengguna."
// @Param        page query int false "Page" minimum(1) default(1)
// @Param        limit query int false "Limit" minimum(1) maximum(50) default(20)
// @Param        sort_by query string false "Sort By" Enums(name, created_at, member_points, email) default(member_points)
// @Param        order query string false "Order By" Enums(asc, desc) default(desc)
// @Success      200 {object} dto.SwaggerResponse{data=dto.FindCustomerResponse,meta=dto.ResponsePagination} "Success get data customer"
// @Failure      400 {object} dto.SwaggerResponse "Parameter tidak valid"
// @Failure      401 {object} dto.SwaggerResponse "Tidak memiliki akses"
// @Failure      406 {object} dto.SwaggerResponse "Gagal mengambil data customer"
// @Router       /customer [get]
func (h *CustomerHandler) FindCustomers(ctx *gin.Context) {
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

	var params dto.FindCustomerRequest
	if err := ctx.ShouldBindQuery(&params); err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    helper.FormatValidationError(err)[0],
			StatusCode: http.StatusBadRequest,
		})
		return
	}

	result, paginationData, err := h.service.FindCustomers(params)
	if err != nil {
		helper.NewErrorResponse(ctx, dto.ResponseApi[any]{
			Message:    err.Error(),
			StatusCode: http.StatusNotAcceptable,
		})
		return
	}

	helper.NewSuccessResponse(ctx, dto.ResponseApi[dto.FindCustomerResponse]{
		Data:       result,
		Message:    "Success get data customer",
		StatusCode: http.StatusOK,
		Meta:       &paginationData,
	})
}
