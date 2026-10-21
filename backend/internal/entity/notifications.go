package entity

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/datatypes"
)

// ============ ENUM ============

type PlatformDeviceTokenEnum string

const (
	PlatformAndroid PlatformDeviceTokenEnum = "android"
)

type StatusNotificationCampaignEnum string

const (
	CampaignStatusDraft      StatusNotificationCampaignEnum = "draft"
	CampaignStatusQueued     StatusNotificationCampaignEnum = "queued"
	CampaignStatusProcessing StatusNotificationCampaignEnum = "processing"
	CampaignStatusDone       StatusNotificationCampaignEnum = "done"
	CampaignStatusFailed     StatusNotificationCampaignEnum = "failed"
)

type SourceNotificationCampaignEnum string

const (
	CampaignSourceManual SourceNotificationCampaignEnum = "manual"
	CampaignSourceAuto   SourceNotificationCampaignEnum = "auto"
)

type TargetTypeNotificationCampaignEnum string

const (
	CampaignTargetAll     TargetTypeNotificationCampaignEnum = "all"
	CampaignTargetSegment TargetTypeNotificationCampaignEnum = "segment"
	CampaignTargetUsers   TargetTypeNotificationCampaignEnum = "users"
)

type StatusNotificationDeliveryEnum string

const (
	DeliveryStatusPending      StatusNotificationDeliveryEnum = "pending"
	DeliveryStatusSent         StatusNotificationDeliveryEnum = "sent"
	DeliveryStatusFailed       StatusNotificationDeliveryEnum = "failed"
	DeliveryStatusInvalidToken StatusNotificationDeliveryEnum = "invalid_token"
)

// ============ ENTITY ============

type DeviceToken struct {
	ID         uuid.UUID               `gorm:"column:id;primaryKey;default:gen_random_uuid()"`
	IdUser     uuid.UUID               `gorm:"column:id_user;not null"`
	FcmToken   string                  `gorm:"column:fcm_token;not null"`
	Platform   PlatformDeviceTokenEnum `gorm:"column:platform;not null"`
	AppVersion *string                 `gorm:"column:app_version"`
	IsActive   bool                    `gorm:"column:is_active;not null;default:true"`
	LastSeenAt time.Time               `gorm:"column:last_seen_at;not null;default:now()"`
	CreatedAt  time.Time               `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt  time.Time               `gorm:"column:updated_at;not null;autoUpdateTime"`
}

func (DeviceToken) TableName() string {
	return "device_tokens"
}

type NotificationCampaign struct {
	ID              uuid.UUID                          `gorm:"column:id;primaryKey;default:gen_random_uuid()"`
	Source          SourceNotificationCampaignEnum     `gorm:"column:source;not null"`
	Title           string                             `gorm:"column:title;not null"`
	Body            string                             `gorm:"column:body;not null"`
	Data            datatypes.JSON                     `gorm:"column:data;type:jsonb;not null;default:'{}'"`
	TargetType      TargetTypeNotificationCampaignEnum `gorm:"column:target_type;not null"`
	TargetFilter    datatypes.JSON                     `gorm:"column:target_filter;type:jsonb"`
	Status          StatusNotificationCampaignEnum     `gorm:"column:status;not null;default:queued"`
	ScheduledAt     *time.Time                         `gorm:"column:scheduled_at"`
	TotalRecipients int                                `gorm:"column:total_recipients;not null;default:0"`
	IdStaff         *uuid.UUID                         `gorm:"column:id_staff"`
	CreatedAt       time.Time                          `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt       time.Time                          `gorm:"column:updated_at;not null;autoUpdateTime"`
	FinishedAt      *time.Time                         `gorm:"column:finished_at"`
}

func (NotificationCampaign) TableName() string {
	return "notification_campaigns"
}

type Notification struct {
	ID         uuid.UUID      `gorm:"column:id;primaryKey;default:gen_random_uuid()"`
	IdUser     uuid.UUID      `gorm:"column:id_user;not null"`
	IdCampaign *uuid.UUID     `gorm:"column:id_campaign"`
	EventType  string         `gorm:"column:event_type;not null"`
	Title      string         `gorm:"column:title;not null"`
	Body       string         `gorm:"column:body;not null"`
	Data       datatypes.JSON `gorm:"column:data;type:jsonb;not null;default:'{}'"`
	DedupKey   *string        `gorm:"column:dedup_key"`
	IsRead     bool           `gorm:"column:is_read;not null;default:false"`
	ReadAt     *time.Time     `gorm:"column:read_at"`
	CreatedAt  time.Time      `gorm:"column:created_at;not null;autoCreateTime"`
}

func (Notification) TableName() string {
	return "notifications"
}

type NotificationDelivery struct {
	ID                uuid.UUID                      `gorm:"column:id;primaryKey;default:gen_random_uuid()"`
	IdNotification    uuid.UUID                      `gorm:"column:id_notification;not null"`
	IdDeviceToken     uuid.UUID                      `gorm:"column:id_device_token;not null"`
	Status            StatusNotificationDeliveryEnum `gorm:"column:status;not null;default:pending"`
	ProviderMessageID *string                        `gorm:"column:provider_message_id"`
	Error             *string                        `gorm:"column:error"`
	Attempts          int16                          `gorm:"column:attempts;not null;default:0"`
	SentAt            *time.Time                     `gorm:"column:sent_at"`
	CreatedAt         time.Time                      `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt         time.Time                      `gorm:"column:updated_at;not null;autoUpdateTime"`
}

func (NotificationDelivery) TableName() string {
	return "notification_deliveries"
}
