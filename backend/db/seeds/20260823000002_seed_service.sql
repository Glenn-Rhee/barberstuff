-- =====================================================================
-- Insert data Service dari sheet "Data Service" ke table service
-- id_store diambil otomatis dari table store berdasarkan nama toko
-- (JOIN), jadi kalau nama toko tidak ditemukan di table store,
-- baris tersebut otomatis DI-SKIP (tidak error, tidak masuk).
-- Matching nama toko dibuat case-insensitive & trim spasi karena
-- penulisan nama toko di sheet Data Service tidak selalu sama persis
-- dengan yang ada di sheet Data Toko (mis. huruf besar/kecil, spasi).
-- =====================================================================

-- +goose Up
-- +goose StatementBegin
INSERT INTO service (name, price, description, status, type, id_store)
SELECT
    v.name,
    v.price,
    v.description,
    'active'::product_status_enum,
    'service'::product_type_enum,
    s.id
FROM (VALUES
  ('Gentlement Hair Cut', 50000.00, 'Cukur Rambut + Cuci', 'Barberstuff Pondok Gede'),
  ('Gentlement Grooming and Relax', 70000.00, 'Cukur Rambut + Cuci dan Pijat 15 Menit', 'Barberstuff Pondok Gede'),
  ('Gentlement Grooming Max', 95000.00, 'Cukur Rambut + Cuci menggunakan Masker Rambut dan Masker Wajah', 'Barberstuff Pondok Gede'),
  ('Gentlement Classic Cut (Longtrim)', 90000.00, 'Cukuran untuk rambut panjang dan menggunakan Masker Rambut', 'Barberstuff Pondok Gede'),
  ('Kids Hair Cut', 40000.00, 'Cukur untuk anak umur 6 tahun kebawah', 'Barberstuff Pondok Gede'),
  ('Kids Grooming', 50000.00, 'Cukur + Cuci untuk anak umur 6 tahun kebawah', 'Barberstuff Pondok Gede'),
  ('Botak Licin', 60000.00, NULL, 'Barberstuff Pondok Gede'),
  ('Black Hair Color', 120000.00, 'Cukur rambut + cuci, warna rambut hitam', 'Barberstuff Pondok Gede'),
  ('Down Perm', 250000.00, NULL, 'Barberstuff Pondok Gede'),
  ('Curly Perm', 350000.00, NULL, 'Barberstuff Pondok Gede'),
  ('Korean Perm', 400000.00, NULL, 'Barberstuff Pondok Gede'),
  ('Hair Coloring Full', 475000.00, NULL, 'Barberstuff Pondok Gede'),
  ('Coloring Highlight', 350000.00, NULL, 'Barberstuff Pondok Gede'),
  ('Bleaching', 250000.00, NULL, 'Barberstuff Pondok Gede'),
  ('Jasa Coloring', 70000.00, NULL, 'Barberstuff Pondok Gede'),
  ('Cuci Blow', 30000.00, NULL, 'Barberstuff Pondok Gede'),
  ('Relax', 35000.00, NULL, 'Barberstuff Pondok Gede'),
  ('Shaving', 20000.00, NULL, 'Barberstuff Pondok Gede'),
  ('Classic Hair Cut', 45000.00, 'Cukur Rambut + Cuci', 'Barberstuff Duta Indah'),
  ('Gentlement Grooming and Relax', 65000.00, 'Cukur Rambut + Cuci dan Pijat 15 Menit', 'Barberstuff Duta Indah'),
  ('Gentlement Grooming Max', 65000.00, 'Cukur Rambut + Cuci menggunakan Masker Rambut dan Masker Wajah', 'Barberstuff Duta Indah'),
  ('Gentlement Grooming', 60000.00, 'Cukuran untuk rambut panjang dan menggunakan Masker Rambut', 'Barberstuff Duta Indah'),
  ('Kids Hair Cut', 30000.00, 'Cukur untuk anak umur 6 tahun kebawah', 'Barberstuff Duta Indah'),
  ('Kids Grooming', 40000.00, 'Cukur + Cuci untuk anak umur 6 tahun kebawah', 'Barberstuff Duta Indah'),
  ('Hair Desain & Hair Tattoo', 90000.00, 'Gentlemens Grooming dan skin rambut serta tambahan warna sedikit', 'Barberstuff Duta Indah'),
  ('Black Hair Color & Grooming', 90000.00, 'Cukur rambut + cuci, warna rambut hitam', 'Barberstuff Duta Indah'),
  ('Smooting', 265000.00, 'Meluruskan rambut', 'Barberstuff Duta Indah'),
  ('Hair Perming', 245000.00, 'Membuat Rambut menjadi ikal/keriting', 'Barberstuff Duta Indah'),
  ('Fashion Hair Color', 230000.00, 'Warna Rambut Trendi + Bleaching & Styling', 'Barberstuff Duta Indah'),
  ('Classic Hair Cut', 50000.00, 'Cukur rambut', 'BARBERSTUFF KARAWANG'),
  ('Gentlement Grooming', 65000.00, 'Cukur rambut + cuci', 'BARBERSTUFF KARAWANG'),
  ('Gentlement Grooming Relax', 70000.00, 'Cukur rambut + cuci dan pijat 15menit', 'BARBERSTUFF KARAWANG'),
  ('Gentlement Grooming Max', 95000.00, 'Cukur rambut + Cuci dan masker wajah', 'BARBERSTUFF KARAWANG'),
  ('Kids Hair Cut', 45000.00, 'Cukur untuk anak umur 6 tahun kebawah', 'BARBERSTUFF KARAWANG'),
  ('Kids Grooming', 50000.00, 'Cukur + cuci untuk anak umur 6 tahun kebawah', 'BARBERSTUFF KARAWANG'),
  ('Botak licin', 60000.00, NULL, 'BARBERSTUFF KARAWANG'),
  ('Black hair coloring', 120000.00, 'Cukur rambut + cuci + warna rambut hitam', 'BARBERSTUFF KARAWANG'),
  ('Smooting', 265000.00, 'Meluruskan rambut', 'BARBERSTUFF KARAWANG'),
  ('shaving', 15000.00, NULL, 'BARBERSTUFF KARAWANG'),
  ('Classic haircut', 45000.00, 'cukur+cuci', 'BARBERSTUFF TENJO'),
  ('Gentlemens grooming', 60000.00, 'cukur+cuci+masker rambut', 'BARBERSTUFF TENJO'),
  ('Gentlemens grooming relax', 65000.00, 'cukur+cuci+pijat 15 menit', 'BARBERSTUFF TENJO'),
  ('Gentlemens grooming max', 65000.00, 'cukur+cuci+masker wajah', 'BARBERSTUFF TENJO'),
  ('kids haircut', 30000.00, 'cukur untuk anak umur 6 tahun kebawah', 'BARBERSTUFF TENJO'),
  ('kids grooming', 40000.00, 'cukur+cuci untuk anak umur 6tahun kebawah', 'BARBERSTUFF TENJO'),
  ('black hair color & grooming', 90000.00, 'cukur+cuci+semir rambut warna hitam', 'BARBERSTUFF TENJO'),
  ('fashion hair color', 230000.00, 'cukur+cuci+warna rambut trending+bleaching+styling', 'BARBERSTUFF TENJO'),
  ('Hair perming', 245000.00, 'cukur+cuci+ membuat rambut menjadi keriting', 'BARBERSTUFF TENJO'),
  ('cuci blow', 15000.00, 'cuci keramas dengan shampo dan blow', 'BARBERSTUFF TENJO'),
  ('Gentlement Hair Cut', 60000.00, 'Cukur Rambut + Cuci', 'BARBERSTUFF PANGKALPINANG'),
  ('Gentlement Classic Cut ( LONG TRIM )', 90000.00, 'Cukuran untuk rambut panjang dan menggunakan Masker Rambut', 'BARBERSTUFF PANGKALPINANG'),
  ('Gentlement Grooming And Relax', 70000.00, 'Cukur Rambut + Cuci dan Pijat 15 Menit', 'BARBERSTUFF PANGKALPINANG'),
  ('Gentlement Grooming Max', 90000.00, 'Cukur Rambut + Cuci menggunakan Masker Rambut dan Masker Wajah', 'BARBERSTUFF PANGKALPINANG'),
  ('Kids Hair Cut', 40000.00, 'Cukur untuk anak umur 6 tahun kebawah', 'BARBERSTUFF PANGKALPINANG'),
  ('Kids Grooming', 50000.00, 'Cukur + Cuci untuk anak umur 6 tahun kebawah', 'BARBERSTUFF PANGKALPINANG'),
  ('Botak Licin', 60000.00, NULL, 'BARBERSTUFF PANGKALPINANG'),
  ('Black Hair Color', 120000.00, 'Cukur rambut + cuci + warna rambut hitam', 'BARBERSTUFF PANGKALPINANG'),
  ('Down Perm', 250000.00, 'Membuat Rambut menjadi ikal/keriting', 'BARBERSTUFF PANGKALPINANG'),
  ('Curly Perm', 350000.00, NULL, 'BARBERSTUFF PANGKALPINANG'),
  ('Korean Perm', 400000.00, NULL, 'BARBERSTUFF PANGKALPINANG'),
  ('Hair Coloring Full', 475000.00, NULL, 'BARBERSTUFF PANGKALPINANG'),
  ('Coloring Highlight', 350000.00, NULL, 'BARBERSTUFF PANGKALPINANG'),
  ('Bleaching', 250000.00, NULL, 'BARBERSTUFF PANGKALPINANG'),
  ('Jasa Coloring', 70000.00, NULL, 'BARBERSTUFF PANGKALPINANG'),
  ('Cuci Blow', 30000.00, 'Cuci Keramas dengan Shampo dan Blow', 'BARBERSTUFF PANGKALPINANG'),
  ('Shaving', 20000.00, 'Mencukur Jambang, Kumis & Jenggot', 'BARBERSTUFF PANGKALPINANG'),
  ('Relax', 35000.00, 'Pijat 15 Menit', 'BARBERSTUFF PANGKALPINANG'),
  ('Gentlement Hair Cut', 30000.00, '(Cukur + Cuci )', 'BARBERSTUFF MARTAPURA'),
  ('Gentlemens Classic Cut (Long Trim)', 60000.00, '(Cukur + Cuci + Masker Rambut + Cuci )', 'BARBERSTUFF MARTAPURA'),
  ('Gentlemens Grooming and Relax', 55000.00, '(Cukur + Cuci + Pijat 15 Menit)', 'BARBERSTUFF MARTAPURA'),
  ('Gentlemens Grooming MAX', 70000.00, '(Cukur + Cuci + Masker Rambut Dan Masker Wajah + Cuci + Stayling)', 'BARBERSTUFF MARTAPURA'),
  ('Kids Hair Cut', 25000.00, '(Cukur)', 'BARBERSTUFF MARTAPURA'),
  ('Kids Grooming', 40000.00, '(Cukur + Cuci)', 'BARBERSTUFF MARTAPURA'),
  ('Botak Licin', 50000.00, '(Botak Licin)', 'BARBERSTUFF MARTAPURA'),
  ('Black Hair Color', 120000.00, '(Cukur Rambut, Cuci, Warna Rambut Hitam)', 'BARBERSTUFF MARTAPURA'),
  ('Down Perm', 250000.00, NULL, 'BARBERSTUFF MARTAPURA'),
  ('Curly Perm', 350000.00, NULL, 'BARBERSTUFF MARTAPURA'),
  ('Korean Perm', 400000.00, NULL, 'BARBERSTUFF MARTAPURA'),
  ('Hair Coloring Full', 475000.00, NULL, 'BARBERSTUFF MARTAPURA'),
  ('Coloring Highlight', 350000.00, NULL, 'BARBERSTUFF MARTAPURA'),
  ('Bleaching', 250000.00, NULL, 'BARBERSTUFF MARTAPURA'),
  ('Jasa Coloring', 70000.00, NULL, 'BARBERSTUFF MARTAPURA'),
  ('Classic Ayah dan Anak', 85000.00, '(Classic Hair Cut + Kids Hair Cut)', 'BARBERSTUFF MARTAPURA'),
  ('Cuci Blow', 30000.00, '(Cuci keramas Dengan Shampo Dan Blow)', 'BARBERSTUFF MARTAPURA'),
  ('Shaving', 20000.00, NULL, 'BARBERSTUFF MARTAPURA'),
  ('Relax', 35000.00, NULL, 'BARBERSTUFF MARTAPURA')
) AS v(name, price, description, store_name)
JOIN store s
    ON LOWER(TRIM(s.name)) = LOWER(TRIM(v.store_name))
   AND s.deleted_at IS NULL;
   
INSERT INTO service (name, price, description, status, type, id_store)
SELECT
    v.name,
    v.price,
    v.description,
    'active'::product_status_enum,
    'package'::product_type_enum,
    s.id
FROM (VALUES
  ('Paket Classic Ayah dan Anak', 85000.00, 'Classic Hair Cut + Kids Hair Cut', 'Barberstuff Pondok Gede'),
  ('Paket Ayah & Anak', 70000.00, 'Classic Hair Cut + Kids Hair Cut', 'Barberstuff Duta Indah'),
  ('Paket Ayah & Anak', 70000.00, 'Classic Hair Cut + Kids Hair Cut', 'Barberstuff Tenjo'),
  ('Paket Ayah & Anak', 85000.00, 'Classic haircut + Kids haircut', 'Barberstuff Karawang'),
  ('Paket Ayah & Anak', 85000.00, 'Classic Hair Cut + Kids Hair Cut', 'Barberstuff Pangkalpinang'),
  ('Paket Ayah & Anak', 85000.00, 'Classic Hair Cut + Kids Hair Cut', 'Barberstuff Martapura')
) AS v(name, price, description, store_name)
JOIN store s
    ON LOWER(TRIM(s.name)) = LOWER(TRIM(v.store_name))
   AND s.deleted_at IS NULL;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DELETE FROM service;   
-- +goose StatementEnd