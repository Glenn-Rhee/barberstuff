package main

import (
	"barberstuff_backend/db"
	"barberstuff_backend/internal/bootstrap"
	"barberstuff_backend/internal/lib"
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
)

// Todo hilangkan validasi username, gapke username lagi

func main() {
	log.Println("Server is starting...")
	db := db.Connect()
	lib.RedisInit()
	h := bootstrap.InitHandlers(db)

	router := gin.Default()

	// Customer register
	router.POST("/auth/register/credential", h.CustomerHandler.CredentialRegister) // 1
	router.POST("/auth/register/oauth", h.CustomerHandler.OauthRegister)

	// Verify OTP
	router.POST("/auth/verify-credential", h.CustomerHandler.VerifyCredential) // 2

	// User Login
	router.POST("/auth/login/credential", h.AuthHandler.CredentialLogin) // 3

	// Validate Provider
	router.POST("/auth/provider", h.AuthHandler.AuthProvider)

	// Forgot Password
	router.POST("/auth/reset-password", h.CustomerHandler.ForgotPassword)

	fmt.Println("Server running on http://localhost:8080")
	router.Run(":8080")
}
