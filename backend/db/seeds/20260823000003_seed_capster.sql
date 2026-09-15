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
INSERT INTO capster (name, id_store, image_url)
SELECT
    v.name,
    s.id,
    v.image_url
FROM (VALUES
  ('Yanto Safutra Capster', 'Barberstuff Duta Indah', 'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8Rzbw7NpjUvgi23mxs4nX7pOWq0VjYfaB5dL8t'),
  ('Farhan Capster', 'Barberstuff Duta Indah', 'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8R77A7uZNCDBwayItUrTSZ5Qh2iOzEWGfomKA6'),
  ('Mualim Capster', 'Barberstuff Tenjo', 'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8RKOWWq83gFHfdOAWoPBE2Vx59TGzw8ulqQbSa'),
  ('Zakaria Capster', 'Barberstuff Tenjo', 'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8Rhz229DTznMEN8Wd4QVKgkTsSXARbFxmOvaPH'),
  ('Nopri Capster', 'Barberstuff Pangkalpinang', 'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8Rgg6HsbBVXYvBmMLx0no87ikFy6W1aSeDRHrC'),
  ('Arief Capster', 'Barberstuff Pangkalpinang', 'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8R402Z6AWiN5t1ZMCpsHu4LmzXFhrfyUIJWg0B'),
  ('Rahul Capster', 'Barberstuff Pangkalpinang', NULL),
  ('Rihad Capster', 'Barberstuff Pondok Gede', 'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8RO8H8lc2pW5EgrYi3n1Bm6hl2zPbFSTDqAOav'),
  ('Deni Capster', 'Barberstuff Pondok Gede', 'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8RYJwQS1hHTwSLQW6jP5mXK0JEDZMoeshfGzgF'),
  ('Abdul Capster', 'Barberstuff Martapura', 'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8RqXtksy5VT1e24gRvrpUskJM8OtmzjHw7ba3u'),
  ('Madun Capster', 'Barberstuff Karawang', 'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8RZxVgggDlXneWLtVipJ8Ds4kq7SvmcugM93oj'),
  ('Hafid Capster', 'Barberstuff Karawang', 'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8RLXrsKLhCkbhU5SeZHDxfNI489odPvtpF7zA0')
  ('Semman Capster', 'Barberstuff Martapura', 'https://u7dpeigjk8.ufs.sh/f/H61vyEBotg8RFOSZQU0ZfeYsFJGdkB63VwXRNmbtpPEvu1Ka')
) AS v(name, store_name, image_url)
JOIN store s
    ON LOWER(TRIM(s.name)) = LOWER(TRIM(v.store_name))
   AND s.deleted_at IS NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM capster;   
-- +goose StatementEnd