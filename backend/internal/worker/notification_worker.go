package worker

import (
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/service"
	"context"
	"time"
)

func RunNotificationDispatcher(ctx context.Context, svc service.NotificationService) {
	const LIMIT = 50
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	for {
		select{
		case <-ctx.Done():
			return
		case <-ticker.C:
			for{
				n, err := svc.DispatchPending(ctx, LIMIT)
				if err != nil {
					helper.Logger("dispatch notif", "notification_worker.go", err)
					break
				}

				if n < LIMIT {
					break
				}
			}
		}
	}
}