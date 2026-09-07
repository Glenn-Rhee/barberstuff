-- +goose Up
-- +goose StatementBegin

INSERT INTO premium_type (name) VALUES
    ('platinum'), ('gold'), ('silver');
INSERT INTO store (
    id,
    name,
    phone_number,
    coordinate,
    open_hour,
    close_hour,
    banner_url,
    address,
    description,
    store_type,
    status
) VALUES (
    '570e69e4-d481-4543-b729-692acafed2a2',
    'Barberstuff Cabang Tebet',
    '081234567890',
    '106.813889,-6.260278',
    '2026-08-31 09:00:00',
    '2026-08-31 21:00:00',
    'https://example.com/images/store-kemang-banner.jpg',
    'Jl. Kemang Raya No. 45, Jakarta Selatan',
    'Cabang baru di kawasan Kemang, Jakarta Selatan',
    'lite',
    'open'
);
INSERT INTO service (
    name,
    price,
    description,
    status,
    type,
    id_store
) VALUES
-- 5 SERVICE
(
    'Haircut',
    50000.00,
    'Layanan potong rambut pria dengan gaya sesuai keinginan pelanggan.',
    'active',
    'service',
    '570e69e4-d481-4543-b729-692acafed2a2'
),
(
    'Hair Wash',
    30000.00,
    'Layanan keramas menggunakan shampoo dan conditioner.',
    'active',
    'service',
    '570e69e4-d481-4543-b729-692acafed2a2'
),
(
    'Hair Coloring',
    150000.00,
    'Layanan pewarnaan rambut dengan pilihan warna sesuai permintaan pelanggan.',
    'active',
    'service',
    '570e69e4-d481-4543-b729-692acafed2a2'
),
(
    'Hair Styling',
    75000.00,
    'Layanan penataan rambut untuk kebutuhan sehari-hari maupun acara khusus.',
    'active',
    'service',
    '570e69e4-d481-4543-b729-692acafed2a2'
),
(
    'Hair Treatment',
    100000.00,
    'Perawatan rambut untuk membantu menjaga kesehatan dan kelembutan rambut.',
    'active',
    'service',
    '570e69e4-d481-4543-b729-692acafed2a2'
),

-- 5 PACKAGE
(
    'Basic Grooming Package',
    100000.00,
    'Paket grooming dasar yang terdiri dari haircut dan hair wash.',
    'active',
    'package',
    '570e69e4-d481-4543-b729-692acafed2a2'
),
(
    'Premium Grooming Package',
    200000.00,
    'Paket grooming lengkap yang terdiri dari haircut, hair wash, dan hair treatment.',
    'active',
    'package',
    '570e69e4-d481-4543-b729-692acafed2a2'
),
(
    'Coloring Package',
    200000.00,
    'Paket pewarnaan rambut yang mencakup hair coloring dan hair treatment.',
    'active',
    'package',
    '570e69e4-d481-4543-b729-692acafed2a2'
),
(
    'Styling Package',
    125000.00,
    'Paket penataan rambut yang terdiri dari hair wash dan hair styling.',
    'active',
    'package',
    '570e69e4-d481-4543-b729-692acafed2a2'
),
(
    'Complete Hair Care Package',
    300000.00,
    'Paket perawatan rambut lengkap yang mencakup haircut, hair wash, hair coloring, dan hair treatment.',
    'active',
    'package',
    '570e69e4-d481-4543-b729-692acafed2a2'
);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM premium_type;   
-- +goose StatementEnd