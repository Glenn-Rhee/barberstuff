package dto

import "barberstuff_backend/internal/entity"

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
