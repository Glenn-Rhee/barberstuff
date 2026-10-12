package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/repository"

	"gorm.io/gorm"
)

type EmployeeService interface {
	CreateEmployee(req dto.CreateEmployeeReq) error
}

type employeeService struct {
	employeeRepo repository.EmployeeRepository
	db           *gorm.DB
}

func NewEmployeeService(er repository.EmployeeRepository, d *gorm.DB) EmployeeService {
	return &employeeService{employeeRepo: er, db: d}
}

func (s *employeeService) CreateEmployee(req dto.CreateEmployeeReq) error {
	return nil
}
