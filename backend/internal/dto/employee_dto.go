package dto

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
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

type GetEmployeeReq struct {
	Query      *string                    `form:"q" binding:"omitempty"`
	IdStore    *string                    `form:"id_store" binding:"omitempty"`
	IdPosition *string                    `form:"id_position" binding:"omitempty"`
	Status     *entity.EmployeeStatusEnum `form:"status" binding:"omitempty,oneof=active inactive"`
	RequestParamsPagination
}

type EmployeeKPI struct {
	TotalEmployees         int64 `json:"total_employees"`
	TotalActiveEmployees   int64 `json:"total_active_employees"`
	TotalInactiveEmployees int64 `json:"total_inactive_employees"`
	TotalStores            int64 `json:"total_stores"`
}

type StoreEmployee struct {
	Id   uuid.UUID `json:"id"`
	Name string    `json:"name"`
}

type EmployeeData struct {
	Id                  uuid.UUID                  `json:"id"`
	Name                string                     `json:"name"`
	Position            GetPositionRes             `json:"position"`
	Store               *StoreEmployee             `json:"store"`
	PhoneNumber         *string                    `json:"phone_number"`
	Status              entity.EmployeeStatusEnum  `json:"status"`
	Gender              *entity.EmployeeGenderEnum `json:"gender"`
	Email               *string                    `json:"email"`
	Address             *string                    `json:"address"`
	NationalIdNumber    *string                    `json:"national_id_number"`
	ImageUrl            *string                    `json:"image_url"`
	IdentityDocumentUrl *string                    `json:"identity_document_url"`
	AccountNumber       *string                    `json:"account_number"`
	BankName            *string                    `json:"bank_name"`
	CreatedAt           time.Time                  `json:"created_at"`
}

type GetEmployeeRes struct {
	KPI       EmployeeKPI    `json:"kpi"`
	Employees []EmployeeData `json:"employees"`
}

type PatchEmployeeReq struct {
	Name                *string                    `json:"name" binding:"omitempty,min=1,max=255"`
	PhoneNumber         *string                    `json:"phone_number" binding:"omitempty,min=9,max=15"`
	BasicSalary         *float64                   `json:"basic_salary" binding:"omitempty,min=1000"`
	Email               *string                    `json:"email" binding:"omitempty,email"`
	Gender              *entity.EmployeeGenderEnum `json:"gender" binding:"omitempty,oneof=male female"`
	DateOfBirth         *time.Time                 `json:"date_of_birth" binding:"omitempty"`
	Address             *string                    `json:"address" binding:"omitempty"`
	NationalIdNumber    *string                    `json:"national_id_number" binding:"omitempty,len=16,numeric"`
	ImageUrl            *string                    `json:"image_url" binding:"omitempty"`
	IdentityDocumentUrl *string                    `json:"identity_document_url" binding:"omitempty"`
	IdPosition          *string                    `json:"id_position" binding:"omitempty"`
	IdStore             *string                    `json:"id_store" binding:"omitempty"`
	AccountNumber       *string                    `json:"account_number" binding:"omitempty"`
	BankName            *string                    `json:"bank_name" binding:"omitempty,min=2,max=50"`
	Status              *entity.EmployeeStatusEnum `json:"status" binding:"omitempty,oneof=active inactive"`
}
