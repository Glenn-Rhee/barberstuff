package bootstrap

import (
	"barberstuff_backend/internal/handler"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/middleware"
	"barberstuff_backend/internal/repository"
	"barberstuff_backend/internal/service"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type Handlers struct {
	CustomerHandler *handler.CustomerHandler
	AuthHandler     *handler.AuthHandler
	StaffHandler    *handler.StaffHandler
	StoreHandler    *handler.StoreHandler
	CapsterHandler  *handler.CapsterHandler
	Servicehandler  *handler.ServiceHandler
	BookingHandler  *handler.BookingHandler
	AuthMiddleware  gin.HandlerFunc
}

func InitHandlers(db *gorm.DB) *Handlers {
	// Repo
	customerRepo := repository.NewCustomerRepository(db)
	authRepo := repository.NewAuthRepository(db)
	staffRepo := repository.NewStaffRepository(db)
	storeRepo := repository.NewStoreRepository(db)
	serviceRepo := repository.NewServiceRepository(db)
	ratingRepo := repository.NewRatingRepository(db)
	capsterRepo := repository.NewCapsterRepository(db)
	premiumTypeRepo := repository.NewPremiumTypeRepository(db)
	bookingRepo := repository.NewBookingRepository(db)
	promoRepo := repository.NewPromoRepository(db)

	// Service
	customerService := service.NewCustomerService(customerRepo, authRepo, db, lib.ClientRedis, premiumTypeRepo)
	authService := service.NewAuthService(authRepo, lib.ClientRedis)
	staffService := service.NewStaffService(storeRepo, staffRepo, authRepo, db)
	storeService := service.NewStoreService(storeRepo, serviceRepo, ratingRepo, capsterRepo, staffRepo)
	capsterService := service.NewCapsterService(capsterRepo, storeRepo)
	serviceService := service.NewServiceService(serviceRepo, storeRepo)
	bookingService := service.NewBookingService(bookingRepo, lib.ClientRedis, capsterRepo, storeRepo, serviceRepo, promoRepo, db)

	// Handler
	customerHandler := handler.NewCustomerHandler(customerService)
	authHandler := handler.NewAuthHandler(authService)
	staffHandler := handler.NewStaffHandler(staffService)
	storeHandler := handler.NewStoreHandler(storeService)
	capsterHandler := handler.NewCapsterHandler(capsterService)
	serviceHandler := handler.NewServiceHandler(serviceService)
	bookingHandler := handler.NewBookingHandler(bookingService)

	// middleware
	authMiddleware := middleware.AuthMiddleware(authRepo, staffRepo, customerRepo)

	return &Handlers{
		CustomerHandler: customerHandler,
		AuthHandler:     authHandler,
		StaffHandler:    staffHandler,
		StoreHandler:    storeHandler,
		AuthMiddleware:  authMiddleware,
		CapsterHandler:  capsterHandler,
		Servicehandler:  serviceHandler,
		BookingHandler:  bookingHandler,
	}
}
