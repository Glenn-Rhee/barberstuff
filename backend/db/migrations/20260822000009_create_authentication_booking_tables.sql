-- +goose Up
-- +goose StatementBegin

-- ============ AUTHENTICATION ============
CREATE TYPE role_enum AS ENUM ('customer', 'cashier', 'admin', 'mitra');

-- id_user sebelumnya polymorphic tanpa FK asli (rawan orphan data).
-- Dipecah jadi 2 kolom nullable + CHECK, integritas dijaga DB:
--   - role = 'customer'                   -> id_customer terisi, id_staff NULL
--   - role IN ('cashier','admin','mitra') -> id_staff terisi, id_customer NULL
CREATE TABLE authentication (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_customer UUID REFERENCES customer(id)  ,
    id_staff UUID REFERENCES staff(id)  ,
    password VARCHAR(255) NOT NULL, -- simpan hash (bcrypt/argon2), bukan plaintext
    role role_enum NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    login_type VARCHAR(20) NOT NULL DEFAULT 'credential',
    oauth_provider VARCHAR(20),
    CONSTRAINT chk_authentication_user_role CHECK (
        (role = 'customer' AND id_customer IS NOT NULL AND id_staff IS NULL)
        OR
        (role IN ('cashier', 'admin', 'mitra') AND id_staff IS NOT NULL AND id_customer IS NULL)
    )
);

CREATE INDEX idx_authentication_id_customer ON authentication(id_customer);
CREATE INDEX idx_authentication_id_staff ON authentication(id_staff);
-- index email dihapus, sudah otomatis ada dari UNIQUE

CREATE TYPE booking_status_enum AS ENUM ('ongoing', 'completed', 'canceled');

-- id_product polymorphic sebelumnya diganti 2 kolom nullable + CHECK:
--   - booking untuk service -> id_service terisi, id_package NULL
--   - booking untuk paket   -> id_package terisi, id_service NULL
CREATE TABLE booking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status_booking booking_status_enum NOT NULL DEFAULT 'ongoing',
    id_store UUID NOT NULL REFERENCES store(id),
    id_user UUID NOT NULL REFERENCES customer(id),
    id_capster UUID REFERENCES capster(id) ON DELETE SET NULL,
    id_service UUID REFERENCES service(id),
    id_package UUID REFERENCES package(id),
    id_promo_claimed UUID REFERENCES promo_claimed(id), -- promo yg dipakai di booking ini (opsional)
    total_price NUMERIC(12,2) NOT NULL DEFAULT 0, -- snapshot harga saat booking dibuat (harga master bisa berubah nanti)
    scheduled_at TIMESTAMP, -- jadwal booking, beda dgn created_at (waktu booking dibuat)
    qr_code VARCHAR(255), -- kode unik utk digenerate jadi QR saat dibutuhkan, bukan gambar mentah
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_booking_product CHECK (
        (id_service IS NOT NULL AND id_package IS NULL)
        OR
        (id_package IS NOT NULL AND id_service IS NULL)
    )
);

CREATE TRIGGER trg_booking_updated_at
    BEFORE UPDATE ON booking
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_booking_id_store ON booking(id_store);
CREATE INDEX idx_booking_id_user ON booking(id_user);
CREATE INDEX idx_booking_id_capster ON booking(id_capster);
CREATE INDEX idx_booking_id_service ON booking(id_service);
CREATE INDEX idx_booking_id_package ON booking(id_package);

-- history sebelumnya cuma duplikat (id_booking, id_user, created_at) tanpa
-- info baru. Diubah jadi log perubahan status booking -> ada jejak audit
-- (dari status apa ke status apa, kapan, siapa yang ubah).
CREATE TABLE booking_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_booking UUID NOT NULL REFERENCES booking(id)  ,
    old_status booking_status_enum,
    new_status booking_status_enum NOT NULL,
    changed_by UUID, -- id_customer atau id_staff, divalidasi di level aplikasi
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_booking_status_history_id_booking ON booking_status_history(id_booking);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS authentication;
DROP TYPE IF EXISTS role_enum;
DROP TABLE IF EXISTS booking_status_history;
DROP TABLE IF EXISTS booking;
DROP TYPE IF EXISTS booking_status_enum;
-- +goose StatementEnd