-- +goose Up
-- +goose StatementBegin
CREATE TYPE employee_status_enum AS ENUM ('active', 'inactive');
CREATE TYPE employee_gender_enum AS ENUM ('male', 'female');
CREATE TABLE position (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    basic_salary NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE employee (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_position UUID NOT NULL REFERENCES position(id),
    id_store UUID REFERENCES store(id),
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    basic_salary NUMERIC(12,2),
    email VARCHAR(255),
    gender employee_gender_enum,
    date_of_birth DATE,
    address TEXT,
    status employee_status_enum NOT NULL DEFAULT 'active',
    national_id_number VARCHAR(32),
    image_url TEXT,
    identity_document_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE INDEX idx_employee_position ON employee (id_position);
CREATE INDEX idx_employee_store ON employee (id_store);
CREATE UNIQUE INDEX idx_position_name_lower
ON position (LOWER(name));

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS position;

DROP TYPE IF EXISTS employee_status_enum;
DROP TYPE IF EXISTS employee_gender_enum;

-- +goose StatementEnd