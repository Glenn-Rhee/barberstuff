package dto

type ResponseApi[T any] struct {
	Data       T      `json:"data"`
	Message    string `json:"message"`
	StatusCode int    `json:"statusCode"`
}
