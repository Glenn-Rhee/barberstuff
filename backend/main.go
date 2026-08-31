package main

import (
	"barberstuff_backend/db"
	"barberstuff_backend/internal/bootstrap"
	"barberstuff_backend/internal/lib"
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	log.Println("Server is starting...")
	db := db.Connect()
	lib.RedisInit()
	h := bootstrap.InitHandlers(db)

	router := gin.Default()

	auth := router.Group("/auth")
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

	fmt.Println("Server running on http://localhost:8080")
	router.Run(":8080")
}
