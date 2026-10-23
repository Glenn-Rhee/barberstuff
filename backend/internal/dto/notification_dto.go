package dto

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/datatypes"
)

type NotifyInput struct {
	IdUser     uuid.UUID
	EventType  string
	Title      string
	Body       string
	Data       map[string]string
	DedupKey   string
	IdCampaign *uuid.UUID
}

type NotifyResult struct {
	Created    bool
	ID         uuid.UUID
	Deliveries int
}

type GetNotificationReq struct {
	Query    *string    `form:"q" binding:"omitempty"`
	BeforeAt *time.Time `form:"before_at" binding:"omitempty"`
	AfterAt  *time.Time `form:"after_at" binding:"omitempty"`
	RequestParamsPagination
}

type NotificationData struct {
	ID        uuid.UUID      `json:"id"`
	EventType string         `json:"event_type"`
	Title     string         `json:"title"`
	Body      string         `json:"body"`
	Data      datatypes.JSON `json:"data"`
	IsRead    bool           `json:"is_read"`
	ReadAt    *time.Time     `json:"read_at"`
	CreatedAt time.Time      `json:"created_at"`
}

type GetNotificationRes struct {
	Notifications []NotificationData `json:"notifications"`
	TotalUnread   int64              `json:"total_unread"`
}

type MarkReadNotifReq struct {
	IDsNotif *[]string `json:"ids_notif" binding:"omitempty"`
	All      *bool     `json:"all" binding:"omitempty"`
}
