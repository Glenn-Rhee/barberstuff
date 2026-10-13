package entity

import (
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
)

type PayrollStatus string

const (
	PayrollDraft PayrollStatus = "draft"
	PayrollSent  PayrollStatus = "sent"
)

type Payroll struct {
	ID            uuid.UUID       `gorm:"column:id;primaryKey;default:gen_random_uuid()"`
	PeriodStart   time.Time       `gorm:"column:period_start;not null"`
	PeriodEnd     time.Time       `gorm:"column:period_end;not null"`
	Status        PayrollStatus   `gorm:"column:status;not null;default:draft"`
	EmployeeCount int             `gorm:"column:employee_count;not null;default:0"`
	TotalSalary   decimal.Decimal `gorm:"column:total_salary;type:numeric(12,2);not null"`
	CreatedAt     time.Time       `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt     time.Time       `gorm:"column:updated_at;not null;autoUpdateTime"`
}

func (Payroll) TableName() string {
	return "payroll"
}

type PayrollItem struct {
	ID           uuid.UUID       `gorm:"column:id;primaryKey;default:gen_random_uuid()"`
	IDPayroll    uuid.UUID       `gorm:"column:id_payroll;not null"`
	IDEmployee   uuid.UUID       `gorm:"column:id_employee;not null"`
	IDStore      uuid.UUID       `gorm:"column:id_store;nott null"`
	PositionName string          `gorm:"column:position_name;not null"`
	BasicSalary  decimal.Decimal `gorm:"column:basic_salary;type:numeric(12,2);not null"`
	Deduction    decimal.Decimal `gorm:"column:deduction;type:numeric(12,2);not null;default:0"`
	TotalSalary  decimal.Decimal `gorm:"column:total_salary;type:numeric(12,2);not null"`
	DaysWorked   int             `gorm:"column:days_worked;not null;default:0"`
	CreatedAt    time.Time       `gorm:"column:created_at;not null;autoCreateTime"`
	Payroll      Payroll         `gorm:"foreignKey:IDPayroll"`
	Employee     Employee        `gorm:"foreignKey:IDEmployee"`
	Store        Store           `gorm:"foreignKey:IDStore"`
}

func (PayrollItem) TableName() string {
	return "payroll_item"
}
