package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type Payroll struct {
	ID          uuid.UUID       `gorm:"column:id;primaryKey;default:gen_random_uuid()"`
	IdEmployee  uuid.UUID       `gorm:"column:id_employee;not null"`
	PeriodMonth string          `gorm:"column:period_month;not null"`
	PeriodYear  string          `gorm:"column:period_year;not null"`
	BasicSalary decimal.Decimal `gorm:"column:basic_salary;type:numeric(12,2);not null"`
	Deduction   decimal.Decimal `gorm:"column:deduction;type:numeric(12,2);not null;default:0"`
	TotalSalary decimal.Decimal `gorm:"column:total_salary;type:numeric(12,2);not null"`
	DaysWorked  int             `gorm:"column:days_worked;not null;default:0"`
	CreatedAt   time.Time       `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time       `gorm:"column:updated_at;not null;autoUpdateTime"`

	Employee Employee `gorm:"foreignKey:IdEmployee"`
}

func (Payroll) TableName() string {
	return "payroll"
}
