package main

import (
	"barberstuff_backend/db"
	_ "barberstuff_backend/docs"
	"barberstuff_backend/internal/bootstrap"
	"barberstuff_backend/internal/lib"
	"fmt"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
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
	h := bootstrap.InitHandlers(db)

	r := gin.Default()

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
		store.PUT("/:id", h.StoreHandler.UpdateStore)
		store.DELETE("/:id", h.StoreHandler.DeleteStore)
		store.GET("/available-slots/:id")
	}

	staff := r.Group("/staff")
	{
		staff.Use(h.AuthMiddleware)
		staff.POST("/", h.StaffHandler.CreateAccountStaff)
		staff.GET("/", h.StaffHandler.GetAccountStaffes)
		staff.PATCH("/:id", h.StaffHandler.UpdateAccountStaff)
		staff.DELETE("/:id", h.StaffHandler.DeleteAccountStaff)
	}

	profile := r.Group("/profile")
	{
		profile.Use(h.AuthMiddleware)
		profile.GET("/customer", h.CustomerHandler.GetProfile)
		profile.GET("/staff", h.StaffHandler.GetProfile)
	}

	capster := r.Group("/capster")
	{
		capster.Use(h.AuthMiddleware)
		capster.POST("/", h.CapsterHandler.Create)
		capster.GET("/", h.CapsterHandler.GetCapsters)
	}

	service := r.Group("/service")
	{
		service.Use(h.AuthMiddleware)
		service.GET("/", h.Servicehandler.GetServices)
	}

	fmt.Println("Server running on http://localhost:8080")
	r.Run(":8080")
}
