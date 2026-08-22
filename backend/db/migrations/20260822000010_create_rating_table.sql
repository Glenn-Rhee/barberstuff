-- +goose Up
-- +goose StatementBegin

CREATE TYPE rating_type_enum AS ENUM ('toko', 'staff');

-- id_rated bersifat polymorphic (bisa mengacu ke toko ATAU capster,
-- ditentukan oleh kolom "type"). Validasi di level aplikasi.
CREATE TABLE rating (
    id UUID PRIMARY KEY,
    message TEXT,
    score SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 5),
    id_user UUID NOT NULL REFERENCES pelanggan(id),
    id_rated UUID NOT NULL,
    type rating_type_enum NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_rating_id_user ON rating(id_user);
CREATE INDEX idx_rating_id_rated ON rating(id_rated, type);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS rating;
DROP TYPE IF EXISTS rating_type_enum;
-- +goose StatementEnd