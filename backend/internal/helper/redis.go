package helper

import (
	"context"
	"time"

	"github.com/redis/go-redis/v9"
)

func AllowAttemp(r *redis.Client, ctx context.Context, key string, maxAttempts int, window time.Duration) (bool, error) {
	count, err := r.Incr(ctx, key).Result()
	if err != nil {
		return false, err
	}

	if count == 1 {
		err := r.Expire(ctx, key, window).Err()
		if err != nil {
			return false, err
		}
	}

	if count > int64(maxAttempts) {
		return false, nil
	}

	return true, nil
}

func GetRemainingTime(r *redis.Client, ctx context.Context, key string) (int, error) {
	ttl, err := r.TTL(ctx, key).Result()
	if err != nil {
		return 0, err
	}
	minutes := int(ttl.Minutes())
	return minutes, nil
}