-- =====================================================================
-- Insert data Capster dari sheet "Data Capster" ke table capster
-- Hanya kolom name dan id_store yang diisi (sesuai permintaan),
-- status pakai default 'active', image_url NULL (tidak ada data gambar).
-- id_store diambil otomatis dari table store berdasarkan nama toko
-- (JOIN), jadi kalau nama toko tidak ditemukan di table store,
-- baris tersebut otomatis DI-SKIP (tidak error, tidak masuk).
-- Matching nama toko dibuat case-insensitive & trim spasi karena
-- penulisan nama toko di sheet Data Capster tidak selalu sama persis
-- dengan yang ada di sheet Data Toko (mis. huruf besar/kecil, spasi).
-- =====================================================================

-- +goose Up
-- +goose StatementBegin
INSERT INTO capster (name, id_store)
SELECT
    v.name,
    s.id
FROM (VALUES
  ('Ariel Capster', 'Barberstuff Pondok Gede'),
  ('Yanto Safutra Capster', 'Barberstuff Duta Indah'),
  ('Farhan Capster', 'Barberstuff Duta Indah'),
  ('Mualim Capster', 'Barberstuff Tenjo'),
  ('Zakaria Capster', 'Barberstuff Tenjo'),
  ('Nopri Capster', 'Barberstuff Pangkalpinang'),
  ('Arief Capster', 'Barberstuff Pangkalpinang'),
  ('Rahul Capster', 'Barberstuff Pangkalpinang'),
  ('Rihad Capster', 'Barberstuff Pondok Gede'),
  ('Deni Capster', 'Barberstuff Pondok Gede'),
  ('Abdul Capster', 'Barberstuff Pondok Gede'),
  ('Madun Capster', 'Barberstuff Pondok Gede'),
  ('Semman Capster', 'Barberstuff Pondok Gede')
) AS v(name, store_name)
JOIN store s
    ON LOWER(TRIM(s.name)) = LOWER(TRIM(v.store_name))
   AND s.deleted_at IS NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM capster;   
-- +goose StatementEnd