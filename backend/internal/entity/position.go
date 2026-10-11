package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type Position struct {
	ID          uuid.UUID       `gorm:"column:id;primaryKey;default:gen_random_uuid()"`
	Name        string          `gorm:"column:name;not null;unique"`
	BasicSalary decimal.Decimal `gorm:"column:basic_salary;not null"`
	CreatedAt   time.Time       `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time       `gorm:"column:updated_at;not null;autoUpdateTime"`
	DeletedAt   *time.Time      `gorm:"column:deleted_at"`
}

func (Position) TableName() string {
	return "position"
}
