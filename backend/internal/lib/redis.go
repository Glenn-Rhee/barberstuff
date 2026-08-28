package lib

import (
	"barberstuff_backend/internal/helper"
	"context"
	"log"
	"os"
	"time"

	"github.com/joho/godotenv"
	"github.com/redis/go-redis/v9"
)

var ClientRedis *redis.Client

func RedisInit() {
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}

	opt, err := redis.ParseURL(os.Getenv("REDIS_URL"))
	if err != nil {
		helper.Logger("Parse redis url", "lib/redis.go", err)
		return
	}

	opt.PoolSize = 10
	opt.MinIdleConns = 2
	opt.DialTimeout = 5 * time.Second
	opt.ReadTimeout = 3 * time.Second
	opt.WriteTimeout = 3 * time.Second

	ClientRedis = redis.NewClient(opt)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := ClientRedis.Ping(ctx).Err(); err != nil  {
		helper.Logger("Failed connect redis", "lib/redis.go", err)
		return
	}

	log.Println("Succes connect Redis")
}
