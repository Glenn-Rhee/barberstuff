-- +goose Up
-- +goose StatementBegin
CREATE TYPE cash_session_type AS ENUM('open', 'closed');
CREATE TYPE payment_type AS ENUM('cash', 'cashless');
CREATE TYPE transaction_type AS ENUM('income', 'outcome');

CREATE TABLE cash_session (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_store UUID NOT NULL REFERENCES store(id),
    saldo_begin NUMERIC(12,2) NOT NULL,
    amount_actual NUMERIC(12,2),
    status cash_session_type NOT NULL DEFAULT 'open',
    closed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_cash_session UUID NOT NULL REFERENCES cash_session(id),
    title VARCHAR(50) NOT NULL,
    payment_type payment_type NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    transaction_type transaction_type NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS cash_session;
DROP TYPE IF EXISTS cash_session_type;
DROP TYPE IF EXISTS payment_type;
DROP TYPE IF EXISTS transaction_type;
-- +goose StatementEnd