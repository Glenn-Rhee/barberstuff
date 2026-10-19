-- +goose Up
-- +goose StatementBegin

-- Trigger function bersama untuk auto-update kolom updated_at di semua tabel
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============ USER TABLES ============
CREATE TABLE premium_type (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(20) NOT NULL UNIQUE,
    min_points INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
 
CREATE TRIGGER trg_premium_type_updated_at
    BEFORE UPDATE ON premium_type
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE customer (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    member_points INT NOT NULL DEFAULT 5,
    id_premium_type UUID REFERENCES premium_type(id),
    image_customer TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_customer_updated_at
    BEFORE UPDATE ON customer
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS premium_type;
DROP TYPE IF EXISTS premium_type_enum;
DROP FUNCTION IF EXISTS set_updated_at();
-- +goose StatementEnd