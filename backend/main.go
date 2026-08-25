package main

import (
	"barberstuff_backend/db"
	"barberstuff_backend/internal/bootstrap"
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	log.Println("Server is starting...")
	db := db.Connect()

	h := bootstrap.InitHandlers(db)

	router := gin.Default()

	router.POST("/auth/register/credential", h.CustomerHandler.CredentialRegister)
	router.POST("/auth/verify-credential", h.CustomerHandler.VerifyCredential)

	fmt.Println("Server running on http://localhost:8080")
	router.Run(":8080")
}
