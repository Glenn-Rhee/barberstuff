-- +goose Up
-- +goose StatementBegin

CREATE TYPE store_status_enum AS ENUM ('open', 'close');

CREATE TABLE store (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    address TEXT,
    coordinate VARCHAR(100), -- format bebas: "longitude,latitude"
    description TEXT,
    phone_number VARCHAR(20),
    status store_status_enum NOT NULL DEFAULT 'open',
    image_store BYTEA,
    id_staff UUID UNIQUE REFERENCES staff(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_store_updated_at
    BEFORE UPDATE ON store
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_store_id_staff ON store(id_staff);

CREATE TYPE capster_status_enum AS ENUM ('active', 'inactive');

CREATE TABLE capster (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    image_capster BYTEA,
    status capster_status_enum NOT NULL DEFAULT 'active', -- nonaktifkan tanpa hapus data (masih dipakai di booking/rating lama)
    id_store UUID NOT NULL REFERENCES store(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_capster_updated_at
    BEFORE UPDATE ON capster
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_capster_id_store ON capster(id_store);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS capster;
DROP TYPE IF EXISTS capster_status_enum;
DROP TABLE IF EXISTS store;
DROP TYPE IF EXISTS store_status_enum;
-- +goose StatementEnd