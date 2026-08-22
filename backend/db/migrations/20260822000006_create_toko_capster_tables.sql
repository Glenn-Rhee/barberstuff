-- +goose Up
-- +goose StatementBegin

CREATE TYPE toko_status_enum AS ENUM ('open', 'close');

CREATE TABLE toko (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    alamat TEXT,
    coordinate VARCHAR(100), -- format bebas: "longitude,latitude"
    description TEXT,
    no_telp VARCHAR(20),
    status toko_status_enum NOT NULL DEFAULT 'open',
    img_toko VARCHAR(500),
    id_admin UUID UNIQUE REFERENCES admin(id),
    id_kasir UUID UNIQUE REFERENCES kasir(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE capster (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    img_capster VARCHAR(500),
    id_toko UUID NOT NULL REFERENCES toko(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_capster_id_toko ON capster(id_toko);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS capster;
DROP TABLE IF EXISTS toko;
DROP TYPE IF EXISTS toko_status_enum;
-- +goose StatementEnd