-- +goose Up
-- +goose StatementBegin

-- ============ USER TABLES ============
CREATE TABLE pelanggan (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    no_telp VARCHAR(20),
    tgl_lahir DATE,
    gender VARCHAR(10),
    username VARCHAR(100) UNIQUE NOT NULL,
    poin_member INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE kasir (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE admin (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE owner (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- ============ AUTHENTIKASI ============
-- id_user bersifat polymorphic (bisa mengacu ke pelanggan/kasir/admin/owner
-- tergantung "role"). PostgreSQL tidak bisa FK ke banyak tabel sekaligus,
-- jadi validasi id_user vs role harus dilakukan di level aplikasi/backend.
CREATE TYPE role_enum AS ENUM ('pelanggan', 'kasir', 'admin', 'owner');

CREATE TABLE authentikasi (
    id UUID PRIMARY KEY,
    id_user UUID NOT NULL,
    password VARCHAR(255) NOT NULL,
    role role_enum NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
);

CREATE INDEX idx_authentikasi_id_user ON authentikasi(id_user);
CREATE INDEX idx_authentikasi_email ON authentikasi(email);

-- ============ OTP ============
-- One-to-one ke pelanggan
CREATE TABLE otp (
    id UUID PRIMARY KEY,
    id_user UUID NOT NULL UNIQUE REFERENCES pelanggan(id) ON DELETE CASCADE,
    otp VARCHAR(6) NOT NULL,
    expired_at TIMESTAMP NOT NULL
);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS otp;
DROP TABLE IF EXISTS authentikasi;
DROP TYPE IF EXISTS role_enum;
DROP TABLE IF EXISTS pelanggan;
DROP TABLE IF EXISTS kasir;
DROP TABLE IF EXISTS admin;
DROP TABLE IF EXISTS owner;
-- +goose StatementEnd