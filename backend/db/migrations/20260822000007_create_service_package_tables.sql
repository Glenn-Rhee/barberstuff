-- +goose Up
-- +goose StatementBegin

CREATE TYPE product_status_enum AS ENUM ('active', 'inactive');
CREATE TYPE product_type_enum AS ENUM ('service', 'package', 'product');
CREATE TABLE service (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_store UUID NOT NULL REFERENCES store(id),
    name VARCHAR(255) NOT NULL,
    price NUMERIC(12,2) NOT NULL DEFAULT 0,
    description TEXT,
    status product_status_enum NOT NULL DEFAULT 'active',
    type product_type_enum NOT NULL,
    image_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE TRIGGER trg_service_updated_at
    BEFORE UPDATE ON service
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS service;
DROP TYPE IF EXISTS product_status_enum;
DROP TYPE IF EXISTS product_type_enum;
-- +goose StatementEnd