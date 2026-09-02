package dto

type StatusResponse string

const (
	StatusSuccess StatusResponse = "success"
	StatusFailed  StatusResponse = "failed"
)

type ResponseApi[T any] struct {
	Data       T              `json:"data"`
	Message    string         `json:"message"`
	StatusCode int            `json:"statusCode"`
	Status     StatusResponse `json:"status"`
}
