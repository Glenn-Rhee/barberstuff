package dto

type StatusResponse string

const (
	StatusSuccess StatusResponse = "success"
	StatusFailed  StatusResponse = "failed"
)

type OrderBy string

const (
	OrderAsc  OrderBy = "asc"
	OrderDesc OrderBy = "desc"
)

type ResponseApi[T any] struct {
	Data       T                   `json:"data"`
	Message    string              `json:"message"`
	StatusCode int                 `json:"statusCode"`
	Status     StatusResponse      `json:"status"`
	Meta       *ResponsePagination `json:"meta,omitempty"`
}

type ResponsePagination struct {
	Page       int `json:"page"`
	Limit      int `json:"limit"`
	TotalData  int `json:"total_data"`
	TotalPages int `json:"total_pages"`
}

// SwaggerResponse hanya dipakai untuk keperluan dokumentasi Swagger (swag).
// Bentuk JSON-nya identik dengan ResponseApi[T], tapi tanpa generic Go,
// karena dukungan generic pada swag masih tidak konsisten antar versi.
// Gunakan pola override field pada anotasi, contoh:
//
//	@Success 200 {object} dto.SwaggerResponse{data=dto.AuthProviderResponse}
//	@Success 200 {object} dto.SwaggerResponse{data=[]dto.StoreData}
//	@Failure 400 {object} dto.SwaggerResponse
type SwaggerResponse struct {
	Data       interface{}    `json:"data"`
	Message    string         `json:"message"`
	StatusCode int            `json:"statusCode"`
	Status     StatusResponse `json:"status"`
}
