package bootstrap

import (
	"barberstuff_backend/internal/handler"
	"barberstuff_backend/internal/repository"
	"barberstuff_backend/internal/service"

	"gorm.io/gorm"
)

type Handlers struct {
	CustomerHandler *handler.CustomerHandler
}

func InitHandlers(db *gorm.DB) *Handlers {
	// Repo
	customerRepo := repository.NewCustomerRepository(db)
	authRepo := repository.NewAuthRepository(db)
	otpRepo := repository.NewOtpRepository(db)
	// Service
	customerService := service.NewCustomerService(customerRepo, authRepo, db, otpRepo)
	customerHandler := handler.NewCustomerHandler(customerService)

	return &Handlers{
		CustomerHandler: customerHandler,
	}
}
