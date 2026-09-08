package helper

import (
	"context"
	"fmt"
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

func AllowResendOTP(r *redis.Client, ctx context.Context, idCustomer string, cooldown time.Duration, maxAttempts int, attemptWindow time.Duration, banDuration time.Duration) (bool, error) {
	banKey := fmt.Sprintf("otp_ban:%v", idCustomer)
	cooldownKey := fmt.Sprintf("otp_cooldown:%v", idCustomer)
	attemptKey := fmt.Sprintf("otp_resend_attempt:%v", idCustomer)

	banned, err := r.Exists(ctx, banKey).Result()
	if err != nil {
		return false, err
	}
	if banned > 0 {
		return false, nil
	}

	stillActive, err := r.Exists(ctx, cooldownKey).Result()
	if err != nil {
		return false, err
	}
	if stillActive > 0 {
		return false, nil
	}

	count, err := r.Incr(ctx, attemptKey).Result()
	if err != nil {
		return false, err
	}

	if count == 1 {
		if err := r.Expire(ctx, attemptKey, attemptWindow).Err(); err != nil {
			return false, err
		}
	}

	if count > int64(maxAttempts) {
		if err := r.Set(ctx, banKey, 1, banDuration).Err(); err != nil {
			return false, err
		}
		return false, nil
	}

	if err := r.Set(ctx, cooldownKey, 1, cooldown).Err(); err != nil {
		return false, err
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
