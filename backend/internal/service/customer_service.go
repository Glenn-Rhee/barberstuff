package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/repository"
	"context"
)

type CustomerService interface {
	CreateCustomer(ctx context.Context, req dto.CreateCustomerRequest) (*dto.CreateCustomerResponse, error)
}

type customerService struct {
	repo repository.CustomerRepository
}

func NewCustomerService(repo repository.CustomerRepository) CustomerService {
	return &customerService{repo: repo}
}

func (c *customerService) CreateCustomer(ctx context.Context, req dto.CreateCustomerRequest)  (*dto.CreateCustomerResponse, error) {
	return &dto.CreateCustomerResponse{}, nil
}
