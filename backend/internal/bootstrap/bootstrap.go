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
	// Customer Modul
	customerRepo := repository.NewCustomerRepository(db)
	customerService := service.NewCustomerService(customerRepo)
	customerHandler := handler.NewCustomerHandler(customerService)

	return &Handlers{
		CustomerHandler: customerHandler,
	}
}
