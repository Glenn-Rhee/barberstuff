package bootstrap

import (
	"barberstuff_backend/internal/handler"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"barberstuff_backend/internal/service"

	"gorm.io/gorm"
)

type Handlers struct {
	CustomerHandler *handler.CustomerHandler
	AuthHandler *handler.AuthHandler
}

func InitHandlers(db *gorm.DB) *Handlers {
	// Repo
	customerRepo := repository.NewCustomerRepository(db)
	authRepo := repository.NewAuthRepository(db)
	
	// Service
	customerService := service.NewCustomerService(customerRepo, authRepo, db, lib.ClientRedis)
	authService := service.NewAuthService(authRepo, lib.ClientRedis)

	// Handler
	customerHandler := handler.NewCustomerHandler(customerService)
	authHandler := handler.NewAuthHandler(authService)

	return &Handlers{
		CustomerHandler: customerHandler,
		AuthHandler: authHandler,
	}
}
