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
	ID            uuid.UUID        `db:"id"`
	Title         string           `db:"title"`
	Status        PromoStatusEnum  `db:"status"`
	Description   *string          `db:"description"`
	DiscountType  DiscountTypeEnum `db:"discount_type"`
	DiscountValue decimal.Decimal  `db:"discount_value"`
	ExpiredAt     *time.Time       `db:"expired_at"`
	ImagePromo    []byte           `db:"image_promo"`
	CreatedAt     time.Time        `db:"created_at"`
	UpdatedAt     time.Time        `db:"updated_at"`
}

type PromoClaimed struct {
	ID        uuid.UUID  `db:"id"`
	IDPromo   uuid.UUID  `db:"id_promo"`
	IDUser    uuid.UUID  `db:"id_user"`
	IsUsed    bool       `db:"is_used"`
	UsedAt    *time.Time `db:"used_at"`
	CreatedAt time.Time  `db:"created_at"`
}