package dto

type CreateAbsentReq struct {
	IdEmployee []string `json:"id_employee" binding:"required"`
	IdStore    string   `json:"id_store" binding:"required"`
}
