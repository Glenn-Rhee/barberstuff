-- +goose Up
-- +goose StatementBegin

INSERT INTO premium_type (name) VALUES
    ('platinum'), ('gold'), ('silver');
    
-- 1. Barberstuff Pondok Gede
INSERT INTO store (name, phone_number, coordinate, open_hour, close_hour, banner_url, address, description, store_type, status)
VALUES (
  'Barberstuff Pondok Gede',
  '08972314505',
  '-6.2812736,106.930027',
  '2026-09-09T09:00:00Z',
  '2026-09-09T22:00:00Z',
  'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8R3HIsTc9dSjia278LrRoyIYcz9tkvHBPJOmVl',
  'Jl. Jatimakmur No.49C, RT.001/RW.011, Jatimakmur, Kec. Pd. Gede, Kota Bks, Jawa Barat 17413',
  'Toko Barberstuff cabang Pondok Gede dengan varian premium',
  'premium',
  'open'
);

-- 2. Barberstuff Duta Indah
INSERT INTO store (name, phone_number, coordinate, open_hour, close_hour, banner_url, address, description, store_type, status)
VALUES (
  'Barberstuff Duta Indah',
  '08972314505',
  '-6.2849007,106.934199',  -- cek ulang longitude, data sumber tidak konsisten
  '2026-09-09T10:00:00Z',
  '2026-09-09T21:00:00Z',
  'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8RAjoAmLjMuZ7xYEWTwVi20bnzlShfoeUL3Nr8',
  'Perumahan Duta Indah, Jatimakmur, Pondok Gede, Kota Bekasi.',
  'Toko Barberstuff cabang Duta Indah dengan varian premium',
  'premium',
  'open'
);

-- 3. Barber Stuff Bali Jimbaran
INSERT INTO store (name, phone_number, coordinate, open_hour, close_hour, banner_url, address, description, store_type, status)
VALUES (
  'Barber Stuff Bali Jimbaran',
  '851-1933-6919',
  '-8.7885959,115.1752581', -- koordinat tidak tersedia di sumber data
  '2026-09-09T10:00:00Z',
  '2026-09-09T21:00:00Z',
  NULL,
  'Jl. Rumah Sakit Unud, Jimbaran, Kec. Kuta Sel., Kabupaten Badung, Bali 80361',
  'Toko Barberstuff cabang Bali Jimbaran dengan varian premium',
  'premium',
  'open'
);

-- 4. Barberstuff Tenjo
INSERT INTO store (name, phone_number, coordinate, open_hour, close_hour, banner_url, address, description, store_type, status)
VALUES (
  'Barberstuff Tenjo',
  '0813-1337-8900',
  '-6.3429212,106.4567601', 
  '2026-09-09T10:00:00Z',
  '2026-09-09T21:00:00Z',
  'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8RvAG0zX9FSf2aVsD3IYTmUrQC9cbWtBMKnpRi',
  'Ruko lavender RDLV, Jl. Podomoro Tenjo No 25 Blok B',
  'Toko barberstuff cabang Tenjo dengan varian premium',
  'premium',
  'open'
);

-- 5. Barberstuff Karawang
INSERT INTO store (name, phone_number, coordinate, open_hour, close_hour, banner_url, address, description, store_type, status)
VALUES (
  'Barberstuff Karawang',
  '0822-5882-1530',
  '8ef59c04-2a5f-487b-8b8a-b45a42748758', -- koordinat tidak tersedia di sumber data
  '2026-09-09T10:00:00Z',
  '2026-09-09T21:00:00Z',
  'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8RYJoGBKvHTwSLQW6jP5mXK0JEDZMoeshfGzgF',
  'Ruko, Jl. Court Yard Blok C VIIA No.15, Puseurjaya, Telukjambe Timur, Karawang,',
  'Toko Barberstuff cabang Karawang dengan varian premium',
  'premium',
  'open'
);

-- 6. Barberstuff Pangkalpinang
INSERT INTO store (name, phone_number, coordinate, open_hour, close_hour, banner_url, address, description, store_type, status)
VALUES (
  'Barberstuff Pangkalpinang',
  '082210027055',
  '-2.1299367,106.112518', -- koordinat tidak tersedia di sumber data
  '2026-09-09T10:00:00Z',
  '2026-09-09T21:00:00Z',
  'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8RWMZ0JOQpN3yjz06bhQBerRKPomFvdTfU2lV9',
  'Jl. Jendral Sudirman, Klenteng Pasar BTC, Pangkalpinang',
  'Toko Barberstuff cabang Pangkalpinang dengan varian premium',
  'premium',
  'open'
);

-- 7. Barberstuff Martapura
INSERT INTO store (name, phone_number, coordinate, open_hour, close_hour, banner_url, address, description, store_type, status)
VALUES (
  'Barberstuff Martapura',
  '082319341073',
  '-3.410819,114.849438', -- koordinat tidak tersedia di sumber data
  '2026-09-09T10:00:00Z',
  '2026-09-09T21:00:00Z',
  'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8RgqQtt4tBVXYvBmMLx0no87ikFy6W1aSeDRHr',
  'Jl. A. Yani Km.40, Cindai Alus, Kota Martapura, Kabupaten Banjar, Kalsel.',
  'Toko Barberstuff cabang Martapura dengan varian premium',
  'premium',
  'open'
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM premium_type;   
-- +goose StatementEnd