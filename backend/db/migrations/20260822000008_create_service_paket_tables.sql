-- +goose Up
-- +goose StatementBegin

CREATE TABLE service (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL DEFAULT 0,
    img_service VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE paket (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(12,2) NOT NULL DEFAULT 0,
    img_paket VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE paket_service (
    id UUID PRIMARY KEY,
    id_service UUID NOT NULL REFERENCES service(id) ON DELETE CASCADE,
    id_paket UUID NOT NULL REFERENCES paket(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(id_service, id_paket)
);

CREATE INDEX idx_paket_service_id_service ON paket_service(id_service);
CREATE INDEX idx_paket_service_id_paket ON paket_service(id_paket);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS paket_service;
DROP TABLE IF EXISTS paket;
DROP TABLE IF EXISTS service;
-- +goose StatementEnd