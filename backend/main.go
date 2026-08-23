package main

import (
	"barberstuff_backend/db"
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	log.Println("Server is starting...")
	db := db.Connect()
	router := gin.Default()

	fmt.Println("Server running on http://localhost:8080")
	router.Run(":8080")
}