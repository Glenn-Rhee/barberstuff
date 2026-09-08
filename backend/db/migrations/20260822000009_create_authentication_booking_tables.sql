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
    id_customer UUID REFERENCES customer(id),
    id_staff UUID REFERENCES staff(id),
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

CREATE TYPE booking_status_enum AS ENUM ('booked', 'progress' ,'completed', 'canceled');
CREATE TYPE booking_type AS ENUM ('scheduled', 'walk_in');
-- id_product polymorphic sebelumnya diganti 2 kolom nullable + CHECK:
CREATE TABLE booking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status_booking booking_status_enum NOT NULL DEFAULT 'booked',
    id_store UUID NOT NULL REFERENCES store(id),
    id_user UUID NOT NULL REFERENCES customer(id),
    id_capster UUID NOT NULL REFERENCES capster(id),
    id_promo_claimed UUID REFERENCES promo_claimed(id),
    total_price NUMERIC(12,2) NOT NULL DEFAULT 0,  -- sekarang = SUM dari booking_item
    scheduled_at TIMESTAMP,
    qr_code VARCHAR(255),
    booking_type booking_type NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE booking_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_booking UUID NOT NULL REFERENCES booking(id),
    id_service UUID NOT NULL REFERENCES service(id),
    price NUMERIC(12,2) NOT NULL,          -- snapshot harga saat itu
    added_on_spot BOOLEAN NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_booking_updated_at
    BEFORE UPDATE ON booking
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_booking_id_store ON booking(id_store);
CREATE INDEX idx_booking_id_user ON booking(id_user);
CREATE INDEX idx_booking_id_capster ON booking(id_capster);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS authentication;
DROP TYPE IF EXISTS role_enum;
DROP TABLE IF EXISTS booking_status_history;
DROP TABLE IF EXISTS booking;
DROP TYPE IF EXISTS booking_status_enum;
DROP TABLE IF EXISTS booking_item;
DROP TYPE IF EXISTS booking_type;
-- +goose StatementEnd