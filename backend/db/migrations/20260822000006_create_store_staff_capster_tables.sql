-- +goose Up
-- +goose StatementBegin

CREATE TYPE store_status_enum AS ENUM ('open', 'close');

CREATE TABLE store (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    coordinate VARCHAR(100), -- format bebas: "longitude,latitude"
    open_hour TIMESTAMP NOT NULL,
    close_hour TIMESTAMP NOT NULL,
    banner_url TEXT,
    address TEXT,
    description TEXT,
    status store_status_enum NOT NULL DEFAULT 'open',
    id_rating UUID NOT NULL REFERENCES rating(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE TRIGGER trg_store_updated_at
    BEFORE UPDATE ON store
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- staff = pegawai internal (cashier / mitra / admin), BUKAN capster
CREATE TABLE staff (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    id_store UUID REFERENCES store(id),
    id_rating UUID NOT NULL REFERENCES rating(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE TRIGGER trg_staff_updated_at
    BEFORE UPDATE ON staff
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TYPE capster_status_enum AS ENUM ('active', 'inactive');

CREATE TABLE capster (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    status capster_status_enum NOT NULL DEFAULT 'active', -- nonaktifkan tanpa hapus data (masih dipakai di booking/rating lama)
    image_url TEXT,
    id_store UUID NOT NULL REFERENCES store(id),
    id_rating UUID NOT NULL REFERENCES rating(id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE TRIGGER trg_capster_updated_at
    BEFORE UPDATE ON capster
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_capster_id_store ON capster(id_store);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS capster;
DROP TYPE IF EXISTS capster_status_enum;
DROP TABLE IF EXISTS store;
DROP TYPE IF EXISTS store_status_enum;
-- +goose StatementEnd