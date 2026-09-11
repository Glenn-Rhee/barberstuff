-- +goose Up
-- +goose StatementBegin

CREATE TYPE rating_type_enum AS ENUM ('store', 'capster', 'staff');

CREATE TABLE rating (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    id_user UUID NOT NULL REFERENCES customer(id),
    id_store UUID REFERENCES store(id),
    id_capster UUID REFERENCES capster(id),
    id_staff UUID REFERENCES staff(id),
    id_booking UUID NOT NULL REFERENCES booking(id),

    type rating_type_enum NOT NULL,
    score SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 5),
    message TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_rating_target CHECK (
        (type = 'store'
            AND id_store IS NOT NULL
            AND id_capster IS NULL
            AND id_staff IS NULL)
        OR
        (type = 'capster'
            AND id_capster IS NOT NULL
            AND id_store IS NULL
            AND id_staff IS NULL)
        OR
        (type = 'staff'
            AND id_staff IS NOT NULL
            AND id_store IS NULL
            AND id_capster IS NULL)
    ),

    CONSTRAINT uq_rating_booking_type UNIQUE (id_booking, type)
);

CREATE TRIGGER trg_rating_updated_at
    BEFORE UPDATE ON rating
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_rating_id_user
    ON rating(id_user);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS rating;
DROP TYPE IF EXISTS rating_type_enum
-- +goose StatementEnd