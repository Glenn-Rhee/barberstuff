-- +goose Up
-- +goose StatementBegin

INSERT INTO premium_type (name) VALUES
    ('platinum'), ('gold'), ('silver');
    
-- 1. Barberstuff Pondok Gede
INSERT INTO store (name, phone_number, coordinate, open_hour, close_hour, banner_url, address, description, store_type, status)
VALUES (
  'Barberstuff Pondok Gede',
  '08972314505',
  '106.821810,-6.193125',
  '2026-09-09T09:00:00Z',
  '2026-09-09T22:00:00Z',
  NULL,
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
  '106.9366931,-6.284902',  -- cek ulang longitude, data sumber tidak konsisten
  '2026-09-09T10:00:00Z',
  '2026-09-09T21:00:00Z',
  NULL,
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
  NULL, -- koordinat tidak tersedia di sumber data
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
  '106.5124,-6.4548',  -- cek ulang, data sumber tidak konsisten
  '2026-09-09T10:00:00Z',
  '2026-09-09T21:00:00Z',
  NULL,
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
  NULL, -- koordinat tidak tersedia di sumber data
  '2026-09-09T10:00:00Z',
  '2026-09-09T21:00:00Z',
  NULL,
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
  NULL, -- koordinat tidak tersedia di sumber data
  '2026-09-09T10:00:00Z',
  '2026-09-09T21:00:00Z',
  NULL,
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
  NULL, -- koordinat tidak tersedia di sumber data
  '2026-09-09T10:00:00Z',
  '2026-09-09T21:00:00Z',
  NULL,
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