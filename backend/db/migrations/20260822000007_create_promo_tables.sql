-- +goose Up
-- +goose StatementBegin

CREATE TYPE promo_status_enum AS ENUM ('visible', 'hide');

CREATE TABLE promo (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    status promo_status_enum NOT NULL DEFAULT 'visible',
    description TEXT,
    expired_at TIMESTAMP,
    img_promo VARCHAR(500),
    total_discount NUMERIC(12,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- many-to-many antara promo & pelanggan
CREATE TABLE promo_claimed (
    id UUID PRIMARY KEY,
    id_promo UUID NOT NULL REFERENCES promo(id) ON DELETE CASCADE,
    id_user UUID NOT NULL REFERENCES pelanggan(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(id_promo, id_user) -- 1 user tidak bisa klaim promo yang sama 2x
);

CREATE INDEX idx_promo_claimed_id_promo ON promo_claimed(id_promo);
CREATE INDEX idx_promo_claimed_id_user ON promo_claimed(id_user);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS promo_claimed;
DROP TABLE IF EXISTS promo;
DROP TYPE IF EXISTS promo_status_enum;
-- +goose StatementEnd