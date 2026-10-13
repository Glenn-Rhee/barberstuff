-- +goose Up
-- +goose StatementBegin
CREATE TYPE status_payroll_enum AS ENUM ('draft', 'sent');
CREATE TABLE absent (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_employee UUID NOT NULL REFERENCES employee(id),
    id_store UUID NOT NULL REFERENCES store(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE payroll (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'draft',
    employee_count INTEGER NOT NULL DEFAULT 0,
    total_salary NUMERIC(14,2) NOT NULL DEFAULT 0,
    sent_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_payroll_period
        CHECK (period_end > period_start),

    CONSTRAINT uq_payroll_period
        UNIQUE (period_start, period_end)
);

CREATE TABLE payroll_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_payroll UUID NOT NULL
        REFERENCES payroll(id),
    id_employee UUID NOT NULL
        REFERENCES employee(id),
    id_store UUID REFERENCES store(id),
    position_name VARCHAR(255) NOT NULL,
    basic_salary NUMERIC(12,2) NOT NULL,
    deduction NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_salary NUMERIC(12,2) NOT NULL,
    days_worked INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_payroll_item_employee
        UNIQUE (id_payroll, id_employee)
);

CREATE INDEX idx_absent_employee ON absent (id_employee);
CREATE INDEX idx_absent_store ON absent (id_store);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS payroll;
DROP TABLE IF EXISTS absent;

DROP TYPE IF EXISTS status_payroll_enum;
-- +goose StatementEnd