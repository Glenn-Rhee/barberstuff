-- +goose Up
-- +goose StatementBegin

CREATE TYPE capster_status_enum AS ENUM ('active', 'inactive');

CREATE TABLE capster (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    title VARCHAR(20) NOT NULL,
    status capster_status_enum NOT NULL DEFAULT 'active', -- nonaktifkan tanpa hapus data (masih dipakai di booking/rating lama)
    image_url TEXT,
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
-- +goose StatementEnd