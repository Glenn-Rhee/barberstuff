package dto

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
)

type StaffRequest struct {
	Name     string `json:"name" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=5"`
}

type CreateAccountStaffRequest struct {
	IdStore string          `json:"id_store" binding:"required"`
	Name    string          `json:"name" binding:"required,min=3"`
	Email   string          `json:"email" binding:"required,email"`
	Role    entity.RoleEnum `json:"role" binding:"required,oneof=cashier mitra"`
}

type QueryParamsAccountStaff struct {
	IdStore string  `form:"id_store"`
	Name    *string `form:"name"`
	Email   *string `form:"email" binding:"omitempty,email"`
}

type StaffAccountsResponse struct {
	Id        uuid.UUID       `json:"id"`
	Name      string          `json:"name"`
	IdStore   uuid.UUID       `json:"id_store"`
	Role      entity.RoleEnum `json:"role"`
	Email     string          `json:"email"`
	CreatedAt time.Time       `json:"created_at"`
}

type UpdateAccountStaffRequest struct {
	Id       string          `json:"id_staff"`
	Name     string          `json:"name" binding:"required,min=3"`
	Role     entity.RoleEnum `json:"role" binding:"required,oneof=cashier mitra"`
	Password string          `json:"password" binding:"required,min=5"`
}

type DeleteAccountStaffRequst struct {
	Id string `json:"id_staff"`
}
