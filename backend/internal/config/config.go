package config

import (
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	FCMEnabled         bool
	FCMCredentialsJSON string
	FCMCredentialsFile string
}

func Load() *Config {
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}

	enabled, _ := strconv.ParseBool(os.Getenv("FCM_ENABLED"))
	return &Config{
		FCMEnabled:         enabled,
		FCMCredentialsJSON: os.Getenv("FCM_CREDENTIALS_JSON"),
		FCMCredentialsFile: os.Getenv("FCM_CREDENTIALS_FILE"),
	}
}
