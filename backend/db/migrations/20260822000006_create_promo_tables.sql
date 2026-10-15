-- +goose Up
-- +goose StatementBegin

CREATE TYPE promo_status_enum AS ENUM ('visible', 'hide');
CREATE TYPE discount_type_enum AS ENUM ('percentage', 'fixed');

CREATE TABLE promo (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    status promo_status_enum NOT NULL DEFAULT 'visible',
    description TEXT,
    discount_type discount_type_enum NOT NULL DEFAULT 'fixed',
    discount_value NUMERIC(12,2) NOT NULL DEFAULT 0, -- nominal (fixed) atau persen 0-100 (percentage)
    usage_limit_per_customer INTEGER,
    start_at TIMESTAMP,
    expired_at TIMESTAMP,
    image_promo TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_promo_discount_value CHECK (
        discount_value >= 0
        AND (discount_type <> 'percentage' OR discount_value <= 100)
    ),
    CONSTRAINT chk_promo_usage_limit
    CHECK (
        usage_limit_per_customer IS NULL
        OR usage_limit_per_customer >= 1
    )
);

CREATE TRIGGER trg_promo_updated_at
    BEFORE UPDATE ON promo
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- many-to-many antara promo & customer, sekaligus melacak status klaim
CREATE TABLE promo_claimed (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_promo UUID NOT NULL REFERENCES promo(id),
    id_user UUID NOT NULL REFERENCES customer(id),
    is_used BOOLEAN NOT NULL DEFAULT FALSE,
    used_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_promo_claimed_id_promo ON promo_claimed(id_promo);
CREATE INDEX idx_promo_claimed_id_user ON promo_claimed(id_user);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS promo_claimed;
DROP TABLE IF EXISTS promo;
DROP TYPE IF EXISTS discount_type_enum;
DROP TYPE IF EXISTS promo_status_enum;
-- +goose StatementEnd