-- +goose Up
-- +goose StatementBegin

CREATE TYPE product_status_enum AS ENUM ('active', 'inactive');

CREATE TABLE service (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL DEFAULT 0,
    duration_minutes INT, -- estimasi durasi, dipakai utk penjadwalan booking
    status product_status_enum NOT NULL DEFAULT 'active',
    image_service_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_service_updated_at
    BEFORE UPDATE ON service
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE package (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL DEFAULT 0,
    duration_minutes INT,
    status product_status_enum NOT NULL DEFAULT 'active',
    image_package_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_package_updated_at
    BEFORE UPDATE ON package
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE package_service (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_service UUID NOT NULL REFERENCES service(id) ON DELETE CASCADE,
    id_package UUID NOT NULL REFERENCES package(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(id_service, id_package)
);

CREATE INDEX idx_package_service_id_service ON package_service(id_service);
CREATE INDEX idx_package_service_id_package ON package_service(id_package);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS package_service;
DROP TABLE IF EXISTS package;
DROP TABLE IF EXISTS service;
DROP TYPE IF EXISTS product_status_enum;
-- +goose StatementEnd