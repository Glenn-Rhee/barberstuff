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
	CustomerHandler     *handler.CustomerHandler
	AuthHandler         *handler.AuthHandler
	StaffHandler        *handler.StaffHandler
	StoreHandler        *handler.StoreHandler
	Servicehandler      *handler.ServiceHandler
	BookingHandler      *handler.BookingHandler
	RatingHandler       *handler.RatingHandler
	UploadHandler       *handler.UploadHandler
	CashSessionHandler  *handler.CashSessionHandler
	TransactionsHandler *handler.TransactionsHandler
	PositionHandler     *handler.PositionHandler
	EmployeeHandler     *handler.EmployeeHandler
	AuthMiddleware      gin.HandlerFunc
	BookingService      service.BookingService
}

func InitHandlers(db *gorm.DB) *Handlers {
	// Repo
	customerRepo := repository.NewCustomerRepository(db)
	authRepo := repository.NewAuthRepository(db)
	staffRepo := repository.NewStaffRepository(db)
	storeRepo := repository.NewStoreRepository(db)
	serviceRepo := repository.NewServiceRepository(db)
	ratingRepo := repository.NewRatingRepository(db)
	premiumTypeRepo := repository.NewPremiumTypeRepository(db)
	bookingRepo := repository.NewBookingRepository(db)
	promoRepo := repository.NewPromoRepository(db)
	bookingItemRepo := repository.NewBookingItemRepository(db)
	cashSessionRepo := repository.NewCashSessionRepository(db)
	transactionsRepo := repository.NewTransactionsRepository(db)
	positionRepo := repository.NewPositionRepository(db)
	employeeRepo := repository.NewEmployeeRepository(db)
	absentRepo := repository.NewAbsentRepository(db)

	// Service
	customerService := service.NewCustomerService(customerRepo, authRepo, db, lib.ClientRedis, premiumTypeRepo, staffRepo)
	authService := service.NewAuthService(authRepo, lib.ClientRedis)
	staffService := service.NewStaffService(storeRepo, staffRepo, authRepo, customerRepo, employeeRepo, bookingRepo, serviceRepo, bookingItemRepo, db)
	storeService := service.NewStoreService(storeRepo, serviceRepo, ratingRepo, staffRepo, db)
	serviceService := service.NewServiceService(serviceRepo, storeRepo, bookingRepo)
	bookingService := service.NewBookingService(bookingRepo, lib.ClientRedis, employeeRepo, storeRepo, serviceRepo, promoRepo, staffRepo, db)
	ratingService := service.NewRatingService(ratingRepo, bookingRepo, employeeRepo, staffRepo, storeRepo, db)
	cashSessionService := service.NewCashSessionService(cashSessionRepo, storeRepo, staffRepo, serviceRepo, employeeRepo, db)
	transactionsService := service.NewTransactionsService(cashSessionRepo, transactionsRepo, bookingRepo, customerRepo, staffRepo, db)
	positionService := service.NewPositionService(positionRepo)
	employeeService := service.NewEmployeeService(employeeRepo, positionRepo, storeRepo, absentRepo, staffRepo, db)

	// Handler
	customerHandler := handler.NewCustomerHandler(customerService)
	authHandler := handler.NewAuthHandler(authService)
	staffHandler := handler.NewStaffHandler(staffService)
	storeHandler := handler.NewStoreHandler(storeService)
	serviceHandler := handler.NewServiceHandler(serviceService)
	bookingHandler := handler.NewBookingHandler(bookingService)
	ratingHandler := handler.NewRatingHandler(ratingService)
	cashSessionHandler := handler.NewCashSessionHandler(cashSessionService)
	transactionsHandler := handler.NewTransactionsHandler(transactionsService)
	uploadHandler := handler.NewUploadHandler()
	positionHandler := handler.NewPositionHandler(positionService)
	employeeHandler := handler.NewEmployeeHandler(employeeService)

	// middleware
	authMiddleware := middleware.AuthMiddleware(authRepo, staffRepo, customerRepo)

	return &Handlers{
		CustomerHandler:     customerHandler,
		AuthHandler:         authHandler,
		StaffHandler:        staffHandler,
		StoreHandler:        storeHandler,
		AuthMiddleware:      authMiddleware,
		Servicehandler:      serviceHandler,
		BookingHandler:      bookingHandler,
		RatingHandler:       ratingHandler,
		BookingService:      bookingService,
		CashSessionHandler:  cashSessionHandler,
		TransactionsHandler: transactionsHandler,
		UploadHandler:       uploadHandler,
		PositionHandler:     positionHandler,
		EmployeeHandler:     employeeHandler,
	}
}
