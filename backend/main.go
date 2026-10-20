package main

import (
	"barberstuff_backend/db"
	_ "barberstuff_backend/docs"
	"barberstuff_backend/internal/bootstrap"
	"barberstuff_backend/internal/lib"
	"context"
	"fmt"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/robfig/cron/v3"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

// @title           BarberStuff Backend API
// @version         1.0
// @description     Dokumentasi API untuk backend BarberStuff
// @host            localhost:8080
// @BasePath        /
// @securityDefinitions.apikey  BearerAuth
// @in                          header
// @name                        Authorization
// @description                 Masukkan token dengan format: Bearer {token}
func main() {
	log.Println("Server is starting...")
	db := db.Connect()
	lib.RedisInit()
	lib.StorageInit()
	h := bootstrap.InitHandlers(db)
	r := gin.Default()
	c := cron.New()

	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}

	if os.Getenv("APP_ENV") == "development" {
		r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	}

	auth := r.Group("/auth")
	{
		register := auth.Group("/register")
		{
			register.POST("/credential", h.CustomerHandler.CredentialRegister)
			register.POST("/oauth", h.CustomerHandler.OauthRegister)
			register.POST("/admin", h.StaffHandler.CreateAdmin)
		}

		auth.POST("/verify-credential", h.CustomerHandler.VerifyCredential)
		auth.POST("/login/credential", h.AuthHandler.CredentialLogin)
		auth.POST("/provider", h.AuthHandler.AuthProvider)
		auth.POST("/forgot", h.CustomerHandler.ForgotPassword)
		auth.POST("/reset", h.AuthHandler.ResetPassword)
		auth.POST("/refresh-token", h.AuthHandler.RefreshToken)
	}

	store := r.Group("/store")
	{
		store.Use(h.AuthMiddleware)
		store.POST("/", h.StoreHandler.CreateNewStore)
		store.GET("/", h.StoreHandler.GetStores)
		store.GET("/:id", h.StoreHandler.GetStore)
		store.PATCH("/:id", h.StoreHandler.UpdateStore)
		store.DELETE("/:id", h.StoreHandler.DeleteStore)
	}

	staff := r.Group("/staff")
	{
		staff.Use(h.AuthMiddleware)
		staff.POST("/", h.StaffHandler.CreateAccountStaff)
		staff.GET("/", h.StaffHandler.GetAccountStaffes)
		staff.PATCH("/:id", h.StaffHandler.UpdateAccountStaff)
		staff.DELETE("/:id", h.StaffHandler.DeleteAccountStaff)
		booking := staff.Group("/booking")
		{
			booking.POST("/", h.StaffHandler.CreateBooking)
			booking.PATCH("/:id", h.StaffHandler.UpdateBooking)
			booking.PATCH("/checkin/:qr_code", h.StaffHandler.CheckinBooking)
			booking.POST("/item", h.StaffHandler.AddBookingItem)
			booking.DELETE("/item", h.StaffHandler.DeleteBookingItem)
		}
	}

	profile := r.Group("/profile")
	{
		profile.Use(h.AuthMiddleware)
		profile.GET("/customer", h.CustomerHandler.GetProfile)
		profile.PATCH("/customer", h.CustomerHandler.UpdateProfile)
		profile.GET("/staff", h.StaffHandler.GetProfile)
	}

	service := r.Group("/service")
	{
		service.Use(h.AuthMiddleware)
		service.GET("/", h.Servicehandler.GetServices)
		service.POST("/", h.Servicehandler.CreateService)
		service.PATCH("/:id", h.Servicehandler.UpdateService)
		service.DELETE("/:id", h.Servicehandler.DeleteService)
	}

	booking := r.Group("/booking")
	{
		booking.Use(h.AuthMiddleware)
		booking.POST("/", h.BookingHandler.CreateBooking)
		booking.GET("/", h.BookingHandler.GetDataBookings)
		booking.GET("/store", h.BookingHandler.GetDataBookingStore)
		booking.GET("/customer", h.BookingHandler.GetDataBookingCustomer)
		booking.POST("/lock", h.BookingHandler.LockBooking)
		booking.DELETE("/lock", h.BookingHandler.DeleteLockBooking)
	}

	customer := r.Group("/customer")
	{
		customer.Use(h.AuthMiddleware)
		customer.GET("/", h.CustomerHandler.FindCustomers)
	}

	rating := r.Group("/rating")
	{
		rating.Use(h.AuthMiddleware)
		rating.POST("/", h.RatingHandler.Create)
		rating.GET("/", h.RatingHandler.GetRating)
	}

	cashSessions := r.Group("/cash-sessions")
	{
		cashSessions.Use(h.AuthMiddleware)
		cashSessions.POST("/", h.CashSessionHandler.Create)
		cashSessions.GET("/", h.CashSessionHandler.GetToday)
		cashSessions.PATCH("/", h.CashSessionHandler.CloseCashSession)
		cashSessions.GET("/history", h.CashSessionHandler.GetHistory)
	}

	transactions := r.Group("/transactions")
	{
		transactions.Use(h.AuthMiddleware)
		transactions.POST("/", h.TransactionsHandler.CreateTransaction)
		transactions.PATCH("/void", h.TransactionsHandler.VoidTransaction)
		title := transactions.Group("/title")
		{
			title.POST("/", h.TransactionsHandler.CreateTitleOutcome)
			title.GET("/", h.TransactionsHandler.GetTitleOutcome)
			title.PATCH("/:id", h.TransactionsHandler.UpdateTitleOutcome)
		}
	}

	position := r.Group("/position")
	{
		position.Use(h.AuthMiddleware)
		position.POST("/", h.PositionHandler.CreatePosition)
		position.GET("/", h.PositionHandler.GetPosition)
		position.PATCH("/:id", h.PositionHandler.UpdatePosition)
		position.DELETE("/:id", h.PositionHandler.DeletePosition)
	}

	employee := r.Group("/employee")
	{
		employee.Use(h.AuthMiddleware)
		employee.POST("/", h.EmployeeHandler.CreateEmployee)
		employee.GET("/", h.EmployeeHandler.GetEmployee)
		employee.PATCH("/:id", h.EmployeeHandler.PatchEmployee)
		employee.DELETE("/:id", h.EmployeeHandler.DeleteEmployee)
		employee.POST("/absent", h.EmployeeHandler.Absent)
		employee.GET("/absent", h.EmployeeHandler.GetEmployeeAbsent)
	}

	promo := r.Group("/promo")
	{
		promo.Use(h.AuthMiddleware)
		promo.POST("/", h.PromoHandler.CreatePromo)
		promo.GET("/", h.PromoHandler.GetPromo)
		promo.PATCH("/:id", h.PromoHandler.PatchPromo)
		promo.DELETE("/:id", h.PromoHandler.DeletePromo)
		promo.POST("/claim/:id", h.PromoHandler.ClaimedPromo)
		promo.GET("/claim", h.PromoHandler.GetClaimPromo)
	}

	benefit := r.Group("/benefit")
	{
		benefit.Use(h.AuthMiddleware)
		benefit.POST("/", h.BenefitHandler.CreateBenefit)
		benefit.GET("/", h.BenefitHandler.GetBenefits)
		benefit.PATCH("/:id", h.BenefitHandler.PatchBenefit)
		benefit.DELETE("/:id", h.BenefitHandler.DeleteBenefit)
	}

	upload := r.Group("/upload")
	{
		upload.Use(h.AuthMiddleware)
		upload.POST("/img/presign", h.UploadHandler.GetImgPresignedURL)
	}

	c.AddFunc("*/5 * * * *", func() {
		if err := h.BookingService.AutoCancelBookings(context.Background()); err != nil {
			log.Println("Error auto cancel booking:", err)
		}
	})
	c.Start()

	fmt.Println("Server running on http://localhost:8080")
	r.Run(":8080")
}
