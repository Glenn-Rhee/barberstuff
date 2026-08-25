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

	router.POST("/customer", h.CustomerHandler.CreateCustomer)

	fmt.Println("Server running on http://localhost:8080")
	router.Run(":8080")
}
