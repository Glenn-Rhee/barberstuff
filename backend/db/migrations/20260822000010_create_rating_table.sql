-- +goose Up
-- +goose StatementBegin

CREATE TYPE rating_type_enum AS ENUM ('store', 'capster');

-- id_rated polymorphic sebelumnya diganti 2 kolom nullable + CHECK, dan
-- dikaitkan ke booking (UNIQUE) supaya 1 booking cuma bisa dirating 1x.
CREATE TABLE rating (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_user UUID NOT NULL REFERENCES customer(id),
    id_store UUID REFERENCES store(id) ON DELETE CASCADE,
    id_capster UUID REFERENCES capster(id) ON DELETE CASCADE,
    type rating_type_enum NOT NULL,
    score SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 5),
    message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_rating_target CHECK (
        (type = 'store' AND id_store IS NOT NULL AND id_capster IS NULL)
        OR
        (type = 'capster' AND id_capster IS NOT NULL AND id_store IS NULL)
    )
);

CREATE TRIGGER trg_rating_updated_at
    BEFORE UPDATE ON rating
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_rating_id_user ON rating(id_user);
CREATE INDEX idx_rating_id_store ON rating(id_store);
CREATE INDEX idx_rating_id_capster ON rating(id_capster);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS rating;
DROP TYPE IF EXISTS rating_type_enum;
-- +goose StatementEnd