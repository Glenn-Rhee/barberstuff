-- +goose Up
-- +goose StatementBegin

CREATE TABLE rating (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_user UUID NOT NULL REFERENCES customer(id),
    score SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 5),
    message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_rating_updated_at
    BEFORE UPDATE ON rating
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_rating_id_user ON rating(id_user);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS rating;
-- +goose StatementEnd