package entity

import (
	"time"

	"github.com/google/uuid"
)

type Absent struct {
	ID         uuid.UUID `gorm:"column:id;primaryKey;default:gen_random_uuid()"`
	IdEmployee uuid.UUID `gorm:"column:id_employee;not null"`
	IdStore    uuid.UUID `gorm:"column:id_store;not null"`
	CreatedAt  time.Time `gorm:"column:created_at;not null;autoCreateTime"`

	Employee Employee `gorm:"foreignKey:IdEmployee"`
	Store    Store    `gorm:"foreignKey:IdStore"`
}

func (Absent) TableName() string {
	return "absent"
}
