package dto

import (
	"barberstuff_backend/internal/entity"
	"time"
)

type CreateEmployeeReq struct {
	Name                string                    `json:"name" binding:"required,min=1,max=255"`
	PhoneNumber         string                    `json:"phone_number" binding:"required,min=9,max=15"`
	BasicSalary         float64                   `json:"basic_salary" binding:"required,min=1000"`
	Email               string                    `json:"email" binding:"required,email"`
	Gender              entity.EmployeeGenderEnum `json:"gender" binding:"required,oneof=male female"`
	DateOfBirth         time.Time                 `json:"date_of_birth" binding:"required"`
	Address             *string                   `json:"address" binding:"omitempty"`
	NationalIdNumber    string                    `json:"national_id_number" binding:"required,len=16,numeric"`
	ImageUrl            *string                   `json:"image_url" binding:"omitempty"`
	IdentityDocumentUrl string                    `json:"identity_document_url" binding:"required"`
	IdPosition          string                    `json:"id_position" binding:"required"`
	IdStore             string                    `json:"id_store" binding:"required"`
	AccountNumber       string                    `json:"account_number" binding:"required"`
	BankName            string                    `json:"bank_name" binding:"required,min=2,max=50"`
}
