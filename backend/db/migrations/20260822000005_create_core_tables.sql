-- +goose Up
-- +goose StatementBegin

-- Trigger function bersama untuk auto-update kolom updated_at di semua tabel
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============ USER TABLES ============
CREATE TYPE premium_type_enum AS ENUM ('newbie', 'bestie', 'royal', 'crazy');
CREATE TABLE customer (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    member_points INT NOT NULL DEFAULT 0,
    premium_type VARCHAR(20) NOT NULL DEFAULT 'newbie' CHECK (premium_type IN ('newbie', 'bestie', 'royal', 'crazy')),
    image_customer TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_customer_updated_at
    BEFORE UPDATE ON customer
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

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
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP
);

CREATE TRIGGER trg_staff_updated_at
    BEFORE UPDATE ON staff
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============ AUTHENTICATION ============
CREATE TYPE role_enum AS ENUM ('customer', 'cashier', 'admin', 'mitra');

-- id_user sebelumnya polymorphic tanpa FK asli (rawan orphan data).
-- Dipecah jadi 2 kolom nullable + CHECK, integritas dijaga DB:
--   - role = 'customer'                   -> id_customer terisi, id_staff NULL
--   - role IN ('cashier','admin','mitra') -> id_staff terisi, id_customer NULL
CREATE TABLE authentication (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_customer UUID REFERENCES customer(id) ON DELETE CASCADE,
    id_staff UUID REFERENCES staff(id) ON DELETE CASCADE,
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

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS otp;
DROP TABLE IF EXISTS authentication;
DROP TYPE IF EXISTS role_enum;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS customer;
DROP TYPE IF EXISTS premium_type_enum;
DROP TABLE IF EXISTS store;
DROP TYPE IF EXISTS store_status_enum;
DROP FUNCTION IF EXISTS set_updated_at();
-- +goose StatementEnd