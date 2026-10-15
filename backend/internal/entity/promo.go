package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type PromoStatusEnum string

const (
	PromoStatusVisible PromoStatusEnum = "visible"
	PromoStatusHide    PromoStatusEnum = "hide"
)

type DiscountTypeEnum string

const (
	DiscountTypePercentage DiscountTypeEnum = "percentage"
	DiscountTypeFixed      DiscountTypeEnum = "fixed"
)

type Promo struct {
	ID                    uuid.UUID        `gorm:"column:id;primaryKey"`
	Title                 string           `gorm:"column:title;not null"`
	Status                PromoStatusEnum  `gorm:"column:status;not null"`
	Description           *string          `gorm:"column:description"`
	DiscountType          DiscountTypeEnum `gorm:"column:discount_type;not null"`
	DiscountValue         decimal.Decimal  `gorm:"column:discount_value;not null;default:0"`
	UsageLimitPerCustomer *int64           `gorm:"column:usage_limit_per_customer"`
	StartAt               *time.Time       `gorm:"column:start_at"`
	ExpiredAt             *time.Time       `gorm:"column:expired_at"`
	ImagePromo            string           `gorm:"column:image_promo"`
	MinMemberPoints       *int64           `gorm:"column:min_member_points"`
	CreatedAt             time.Time        `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt             time.Time        `gorm:"column:updated_at;not null;autoUpdateTime"`
	DeletedAt             *time.Time       `gorm:"column:deleted_at"`
}

func (Promo) TableName() string {
	return "promo"
}

type PromoClaimed struct {
	ID        uuid.UUID  `gorm:"column:id;primaryKey"`
	IDPromo   uuid.UUID  `gorm:"column:id_promo;not null"`
	IDUser    uuid.UUID  `gorm:"column:id_user;not null"`
	IsUsed    bool       `gorm:"column:is_used;not null;default:false"`
	UsedAt    *time.Time `gorm:"column:used_at"`
	CreatedAt time.Time  `gorm:"column:created_at;not null;autoCreateTime"`
	Promo     Promo      `gorm:"foreignKey:IDPromo"`
}

func (PromoClaimed) TableName() string {
	return "promo_claimed"
}
