-- +goose Up
-- +goose StatementBegin

CREATE TYPE booking_status_enum AS ENUM ('ongoing', 'completed', 'canceled');

-- id_produk bersifat polymorphic (bisa mengacu ke service ATAU paket),
-- validasi kesesuaian id_produk dilakukan di level aplikasi.
CREATE TABLE booking (
    id UUID PRIMARY KEY,
    status_booking booking_status_enum NOT NULL DEFAULT 'ongoing',
    id_toko UUID NOT NULL REFERENCES toko(id),
    id_user UUID NOT NULL REFERENCES pelanggan(id),
    id_produk UUID NOT NULL,
    id_capster UUID REFERENCES capster(id),
    img_qr VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_booking_id_toko ON booking(id_toko);
CREATE INDEX idx_booking_id_user ON booking(id_user);
CREATE INDEX idx_booking_id_capster ON booking(id_capster);

CREATE TABLE history (
    id UUID PRIMARY KEY,
    id_booking UUID NOT NULL REFERENCES booking(id) ON DELETE CASCADE,
    id_user UUID NOT NULL REFERENCES pelanggan(id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_history_id_booking ON history(id_booking);
CREATE INDEX idx_history_id_user ON history(id_user);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS history;
DROP TABLE IF EXISTS booking;
DROP TYPE IF EXISTS booking_status_enum;
-- +goose StatementEnd