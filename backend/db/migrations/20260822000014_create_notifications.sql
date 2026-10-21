-- +goose Up
-- +goose StatementBegin

CREATE TYPE platform_device_token_enum AS ENUM ('android');
CREATE TYPE status_notification_campaign_enum
    AS ENUM ('draft', 'queued', 'processing', 'done', 'failed');
CREATE TYPE source_notification_campaign_enum AS ENUM ('manual', 'auto');
CREATE TYPE target_type_notification_campaign_enum
    AS ENUM ('all', 'segment', 'users');
CREATE TYPE status_notification_delivery_enum
    AS ENUM ('pending', 'sent', 'failed', 'invalid_token');

CREATE TABLE device_tokens (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_user       UUID NOT NULL REFERENCES customer(id),
    fcm_token     TEXT NOT NULL UNIQUE,
    platform      platform_device_token_enum NOT NULL,
    app_version   VARCHAR(20),
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    last_seen_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_device_tokens_user_active
    ON device_tokens(id_user) WHERE is_active;

CREATE TRIGGER trg_device_tokens_updated_at
    BEFORE UPDATE ON device_tokens
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE notification_campaigns (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source           source_notification_campaign_enum NOT NULL,
    title            VARCHAR(150) NOT NULL,
    body             TEXT NOT NULL,
    data             JSONB NOT NULL DEFAULT '{}',
    target_type      target_type_notification_campaign_enum NOT NULL,
    target_filter    JSONB,
    status           status_notification_campaign_enum NOT NULL DEFAULT 'queued',
    scheduled_at     TIMESTAMP,
    total_recipients INTEGER NOT NULL DEFAULT 0,
    id_staff         UUID REFERENCES staff(id), -- NULL jika source = 'auto'
    created_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP NOT NULL DEFAULT NOW(),
    finished_at      TIMESTAMP
);

CREATE TRIGGER trg_notification_campaigns_updated_at
    BEFORE UPDATE ON notification_campaigns
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE notifications (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_user       UUID NOT NULL REFERENCES customer(id),
    id_campaign   UUID REFERENCES notification_campaigns(id),
    event_type    VARCHAR(50) NOT NULL,
    title         VARCHAR(150) NOT NULL,
    body          TEXT NOT NULL,
    data          JSONB NOT NULL DEFAULT '{}',
    dedup_key     VARCHAR(150),
    is_read       BOOLEAN NOT NULL DEFAULT FALSE,
    read_at       TIMESTAMP,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notif_user_created ON notifications(id_user, created_at DESC);
CREATE INDEX idx_notif_user_unread  ON notifications(id_user) WHERE is_read = FALSE;
CREATE UNIQUE INDEX uq_notif_dedup  ON notifications(id_user, dedup_key) WHERE dedup_key IS NOT NULL;
CREATE INDEX idx_notif_campaign     ON notifications(id_campaign) WHERE id_campaign IS NOT NULL;

CREATE TABLE notification_deliveries (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_notification     UUID NOT NULL REFERENCES notifications(id),
    id_device_token     UUID NOT NULL REFERENCES device_tokens(id),
    status              status_notification_delivery_enum NOT NULL DEFAULT 'pending',
    provider_message_id TEXT,
    error               TEXT,
    attempts            SMALLINT NOT NULL DEFAULT 0,
    sent_at             TIMESTAMP,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_deliveries_status
    ON notification_deliveries(status) WHERE status IN ('pending', 'failed');
CREATE INDEX idx_deliveries_notification ON notification_deliveries(id_notification);

CREATE TRIGGER trg_notification_deliveries_updated_at
    BEFORE UPDATE ON notification_deliveries
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS notification_deliveries;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS notification_campaigns;
DROP TABLE IF EXISTS device_tokens;

DROP TYPE IF EXISTS status_notification_delivery_enum;
DROP TYPE IF EXISTS target_type_notification_campaign_enum;
DROP TYPE IF EXISTS source_notification_campaign_enum;
DROP TYPE IF EXISTS status_notification_campaign_enum;
DROP TYPE IF EXISTS platform_device_token_enum;
-- +goose StatementEnd