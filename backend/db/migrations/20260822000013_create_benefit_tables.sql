-- +goose Up
-- +goose StatementBegin
CREATE TYPE benefit_status_enum AS ENUM ('visible', 'hide');

CREATE TABLE benefit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT,
    status benefit_status_enum NOT NULL DEFAULT 'visible',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_benefit_updated_at
    BEFORE UPDATE ON benefit
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS benefit;
DROP TYPE IF EXISTS benefit_status_enum;
-- +goose StatementEnd