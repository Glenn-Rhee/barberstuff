package main

import (
	"barberstuff_backend/db"
	"barberstuff_backend/internal/bootstrap"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/middleware"
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	log.Println("Server is starting...")
	db := db.Connect()
	lib.RedisInit()
	h := bootstrap.InitHandlers(db)

	r := gin.Default()

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
	}

	store := r.Group("/store")
	{
		store.Use(middleware.AuthMiddleware)
		store.POST("/", h.StoreHandler.CreateNewStore)
		store.GET("/", h.StoreHandler.GetStores)
		store.GET("/:id", h.StoreHandler.GetStore)
		store.PUT("/:id", h.StoreHandler.UpdateStore)
		store.DELETE("/:id", h.StoreHandler.DeleteStore)
	}

	staff := r.Group("/staff")
	{
		staff.Use(middleware.AuthMiddleware)
		staff.POST("/", h.StaffHandler.CreateAccountStaff)
		staff.GET("/", h.StaffHandler.GetAccountStaffes)
	}

	fmt.Println("Server running on http://localhost:8080")
	r.Run(":8080")
}
