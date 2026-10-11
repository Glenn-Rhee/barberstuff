-- +goose Up
-- +goose StatementBegin

CREATE TABLE absent (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_employee UUID NOT NULL REFERENCES employee(id),
    id_store UUID NOT NULL REFERENCES store(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE payroll (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_employee UUID NOT NULL REFERENCES employee(id),
    period_month VARCHAR(50) NOT NULL,
    period_year VARCHAR(4) NOT NULL,
    basic_salary NUMERIC(12,2) NOT NULL,
    deduction NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_salary NUMERIC(12,2) NOT NULL,
    days_worked INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_payroll_employee_period
        UNIQUE (id_employee, period_month, period_year)
);

CREATE INDEX idx_absent_employee ON absent (id_employee);
CREATE INDEX idx_absent_store ON absent (id_store);
CREATE INDEX idx_payroll_employee ON payroll (id_employee);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS payroll;
DROP TABLE IF EXISTS absent;

-- +goose StatementEnd