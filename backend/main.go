package main

import (
	"barberstuff_backend/db"
	"barberstuff_backend/internal/bootstrap"
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
)

// Todo hilangkan validasi username, gapke username lagi

func main() {
	log.Println("Server is starting...")
	db := db.Connect()

	h := bootstrap.InitHandlers(db)

	router := gin.Default()

	// Customer register
	router.POST("/auth/register/credential", h.CustomerHandler.CredentialRegister)
	router.POST("/auth/register/oauth", h.CustomerHandler.OauthRegister)

	// Verify Token
	router.POST("/auth/verify-credential", h.CustomerHandler.VerifyCredential)

	// User Login with credential
	router.POST("/auth/login/credential", h.AuthHandler.CredentialLogin)

	fmt.Println("Server running on http://localhost:8080")
	router.Run(":8080")
}
