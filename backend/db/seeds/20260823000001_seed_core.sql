-- +goose Up
-- +goose StatementBegin

INSERT INTO premium_type (name) VALUES
    ('platinum'), ('gold'), ('silver');

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM premium_type; 
-- +goose StatementEnd