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
	AuthHandler     *handler.AuthHandler
	StaffHandler    *handler.StaffHandler
	StoreHandler    *handler.StoreHandler
}

func InitHandlers(db *gorm.DB) *Handlers {
	// Repo
	customerRepo := repository.NewCustomerRepository(db)
	authRepo := repository.NewAuthRepository(db)
	staffRepo := repository.NewStaffRepository(db)
	storeRepo := repository.NewStoreRepository(db)

	// Service
	customerService := service.NewCustomerService(customerRepo, authRepo, db, lib.ClientRedis)
	authService := service.NewAuthService(authRepo, lib.ClientRedis)
	staffService := service.NewStaffService(staffRepo, authRepo, db)
	storeService := service.NewStoreService(storeRepo)

	// Handler
	customerHandler := handler.NewCustomerHandler(customerService)
	authHandler := handler.NewAuthHandler(authService)
	staffHandler := handler.NewStaffHandler(staffService)
	storeHandler := handler.NewStoreHandler(storeService)

	return &Handlers{
		CustomerHandler: customerHandler,
		AuthHandler:     authHandler,
		StaffHandler:    staffHandler,
		StoreHandler:    storeHandler,
	}
}
