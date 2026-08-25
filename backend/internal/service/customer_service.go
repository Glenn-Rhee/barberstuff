package service

import "context"

type CustomerService interface {
	CreateCustomer(ctx context.Context, req)
}