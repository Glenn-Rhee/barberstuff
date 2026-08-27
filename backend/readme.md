# Backend API Documentation

Backend aplikasi ini dibangun menggunakan bahasa pemrograman Go (Golang).

## 1. Setup Environment

Sebelum menjalankan backend, buat file `.env` berdasarkan file `.env.example`.

Isi konfigurasi environment variable berikut:

```env
DB_HOST=
DB_USER=
DB_PORT=
DB_PASSWORD=
DB_NAME=

JWT_KEY=

SMTP_PASSWORD=
SMTP_HOST=
SMTP_USERNAME=
SMTP_FROM_EMAIL=
SMTP_FROM_NAME=
SMTP_PORT=

OTP_ENCRYPTION_KEY=
```

Contoh:

```env
DB_HOST=localhost
DB_USER=postgres
DB_PORT=5432
DB_PASSWORD=your_password
DB_NAME=your_database

JWT_KEY=sangat_rahasia

SMTP_PASSWORD="goxv vfkk kuzz rnry"
SMTP_HOST="smtp.gmail.com"
SMTP_USERNAME="glennviktor5@gmail.com"
SMTP_FROM_EMAIL="glennviktor5@gmail.com"
SMTP_FROM_NAME="Barberstuff"
SMTP_PORT="587"

OTP_ENCRYPTION_KEY="cihuy123sebanyak32karakter"
```

Pastikan seluruh konfigurasi database sudah sesuai dengan database yang digunakan.

---

## 2. Database Migration

Setelah environment selesai dikonfigurasi, jalankan proses migrasi database menggunakan perintah berikut:

```bash
go run cmd/migrate/main.go <command>
```

Command yang tersedia:

### up

Menjalankan atau menerapkan semua file migrasi baru yang belum dieksekusi ke dalam database.

```bash
go run cmd/migrate/main.go up
```

### down

Melakukan pembatalan (rollback) tepat satu langkah migrasi terakhir yang telah diterapkan.

```bash
go run cmd/migrate/main.go down
```

### status

Menampilkan daftar seluruh file migrasi beserta statusnya saat ini di database.

```bash
go run cmd/migrate/main.go status
```

### reset

Melakukan pembatalan total (rollback all) terhadap seluruh migrasi yang pernah dijalankan dari awal.

```bash
go run cmd/migrate/main.go reset
```

---

## 3. Dummy Data / Database Seeder

Untuk memasukkan data dummy ke dalam database, gunakan perintah:

```bash
go run cmd/seed/main.go <command>
```

Command yang tersedia:

### up

Menjalankan proses seeding dan memasukkan seluruh data dummy ke dalam database.

```bash
go run cmd/seed/main.go up
```

### down

Menghapus atau membatalkan data dummy yang telah dimasukkan oleh proses seeding.

```bash
go run cmd/seed/main.go down
```

### status

Menampilkan status proses seeding yang tersedia atau telah dijalankan.

```bash
go run cmd/seed/main.go status
```

### reset

Melakukan reset terhadap seluruh data dummy dengan membatalkan seluruh proses seeding.

```bash
go run cmd/seed/main.go reset
```

---

## 4. Menjalankan Backend

Setelah environment, migration, dan dummy data selesai dikonfigurasi, jalankan aplikasi backend menggunakan:

```bash
go run main.go
```

Pastikan proses migration telah dijalankan terlebih dahulu agar struktur database sudah tersedia.

---

# API Documentation

## Base Response

Seluruh endpoint API menggunakan format response yang memiliki struktur dasar sebagai berikut:

```go
type ResponseApi[T any] struct {
    Data       T      `json:"data:"`
    Message    string `json:"message"`
    StatusCode int    `json:"statusCode"`
}
```

Secara umum, struktur response dapat dipahami sebagai berikut:

| Key          | Tipe Data             | Keterangan                                                                       |
| ------------ | --------------------- | -------------------------------------------------------------------------------- |
| `data`       | Object / Array / null | Data yang dikembalikan oleh API. Tipe datanya dapat berbeda tergantung endpoint. |
| `message`    | String                | Pesan yang menjelaskan hasil proses API.                                         |
| `statusCode` | Integer               | HTTP status code yang menunjukkan hasil proses request.                          |

---

# Authentication API

## 1. Credential Register

Endpoint ini digunakan untuk melakukan pendaftaran akun menggunakan email dan password.

Setelah proses pendaftaran berhasil, sistem akan mengirimkan OTP ke email pengguna. OTP tersebut kemudian digunakan pada endpoint verifikasi credential.

### Endpoint

```http
POST /auth/register/credential
```

### Request Body

```json
{
  "name": "Budi Santoso",
  "phoneNumber": "081234567890",
  "date_of_birth": "2000-05-15T00:00:00Z",
  "gender": "male",
  "email": "rielyb2005@gmail.com",
  "password": "SecurePass123"
}
```

### Request Body Parameters

| Key             | Tipe Data     | Required | Keterangan                                                              |
| --------------- | ------------- | -------- | ----------------------------------------------------------------------- |
| `name`          | String        | Ya       | Nama lengkap pengguna.                                                  |
| `phoneNumber`   | String        | Ya       | Nomor telepon pengguna, minimal 9 dan maksimal 15 karakter.             |
| `date_of_birth` | Date/DateTime | Ya       | Tanggal lahir pengguna dalam format ISO 8601.                           |
| `gender`        | String        | Ya       | Jenis kelamin pengguna. Nilai yang diperbolehkan: `male` atau `female`. |
| `email`         | String        | Ya       | Alamat email pengguna dengan format email yang valid.                   |
| `password`      | String        | Ya       | Password pengguna, minimal 5 karakter.                                  |

### Aturan Validasi

- `name` wajib diisi.
- `phoneNumber` wajib diisi.
- `phoneNumber` memiliki panjang minimal 9 karakter.
- `phoneNumber` memiliki panjang maksimal 15 karakter.
- `date_of_birth` wajib diisi.
- `gender` wajib diisi dan hanya menerima `male` atau `female`.
- `email` wajib diisi dan harus memiliki format email yang valid.
- `password` wajib diisi dan memiliki panjang minimal 5 karakter.

### Response Sukses

Jika registrasi berhasil, API mengembalikan informasi dasar user dan OTP dikirimkan ke email pengguna.

```json
{
  "data": {
    "id": "633dc6e5-89e3-487d-8e9b-86cc23b71799",
    "email": "aaa@gmail.com"
  },
  "message": "OTP telah dikirim ke email Anda. Silakan periksa kotak masuk atau spam.",
  "statusCode": 200
}
```

Struktur `data` pada response sukses:

| Key        | Tipe Data | Keterangan                            |
| ---------- | --------- | ------------------------------------- |
| `id`       | String    | ID unik user.                         |
| `email`    | String    | Email user yang telah didaftarkan.    |

### Response Gagal

Jika terjadi kesalahan ketika melakukan registrasi:

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!",
  "statusCode": 406
}
```

Pada response gagal:

- `data` memiliki nilai `null` karena tidak ada data user yang dikembalikan.
- `message` berisi informasi mengenai hasil proses.
- `statusCode` bernilai `406`.

---

## 2. Verify Credential / OTP

Endpoint ini digunakan untuk melakukan verifikasi akun menggunakan OTP yang telah dikirimkan ke email pengguna setelah proses registrasi.

### Endpoint

```http
POST /auth/verify-credential
```

### Request Body

```json
{
  "user_id": "c4e8f131-f41a-4afc-8d8a-02810cafa920",
  "otp": "793080"
}
```

### Request Body Parameters

| Key       | Tipe Data | Required | Keterangan                                                                        |
| --------- | --------- | -------- | --------------------------------------------------------------------------------- |
| `user_id` | String    | Ya       | ID unik user yang akan diverifikasi.                                              |
| `otp`     | String    | Ya       | Kode OTP yang diterima melalui email. OTP harus terdiri dari tepat 6 digit angka. |

### Aturan Validasi

- `user_id` wajib diisi.
- `otp` wajib diisi.
- `otp` harus memiliki panjang tepat 6 karakter.
- `otp` hanya boleh berisi angka.

### Response

Endpoint ini mengembalikan `data` dengan nilai `null`. Informasi hasil proses disampaikan melalui `message` dan `statusCode`.

Contoh response ketika verifikasi berhasil:

```json
{
  "data": null,
  "message": "Berhasil verifikasi akun! Silahkan login.",
  "statusCode": 200
}
```

Struktur response:

| Key          | Tipe Data | Keterangan                                               |
| ------------ | --------- | -------------------------------------------------------- |
| `data`       | null      | Tidak terdapat data yang dikembalikan oleh endpoint ini. |
| `message`    | String    | Pesan yang menjelaskan hasil verifikasi.                 |
| `statusCode` | Integer   | HTTP status code dari hasil proses.                      |

---

## 3. Credential Login

Endpoint ini digunakan untuk melakukan login user menggunakan email dan password. Endpoint ini bersifat umum dan dapat digunakan oleh seluruh role pengguna, yaitu customer, kasir, admin, maupun owner.

Untuk customer, endpoint ini dapat digunakan apabila user melakukan login secara manual menggunakan email dan password.

### Endpoint

```http
POST /auth/login/credential
```

### Request Body

```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

### Request Body Parameters

| Key        | Tipe Data | Required | Keterangan                                                                                         |
| ---------- | --------- | -------- | -------------------------------------------------------------------------------------------------- |
| `email`    | String    | Ya       | Email yang terdaftar pada sistem. Harus memiliki format email yang valid.                          |
| `password` | String    | Ya       | Password akun yang digunakan untuk proses autentikasi. Password harus memiliki minimal 5 karakter. |

### Aturan Validasi

- `email` wajib diisi.
- `email` harus memiliki format email yang valid.
- `password` wajib diisi.
- `password` harus memiliki minimal 5 karakter.
- Credential yang diberikan harus sesuai dengan data akun yang terdaftar pada sistem.
- Akun harus sudah terverifikasi agar dapat melakukan login.

### Response

Endpoint ini mengembalikan data berupa informasi autentikasi user dan access token yang dapat digunakan untuk mengakses endpoint yang membutuhkan autentikasi.

Contoh response ketika login berhasil:

```json
{
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "user_id": "c4e8f131-f41a-4afc-8d8a-02810cafa920",
      "email": "user@example.com",
      "role": "customer"
    }
  },
  "message": "Berhasil login.",
  "statusCode": 200
}
```

### Response Data

| Key            | Tipe Data | Keterangan                                                                                                    |
| -------------- | --------- | ------------------------------------------------------------------------------------------------------------- |
| `access_token` | String    | JSON Web Token (JWT) yang digunakan sebagai kredensial untuk mengakses endpoint yang membutuhkan autentikasi. |
| `user`         | Object    | Informasi user yang berhasil melakukan login.                                                                 |

### User Object

| Key       | Tipe Data | Keterangan                                                                  |
| --------- | --------- | --------------------------------------------------------------------------- |
| `user_id` | String    | ID unik user yang berhasil melakukan login.                                 |
| `email`   | String    | Email user yang digunakan untuk login.                                      |
| `role`    | String    | Role user dalam sistem, seperti `customer`, `kasir`, `admin`, atau `owner`. |

### Struktur Response

| Key          | Tipe Data | Keterangan                                                             |
| ------------ | --------- | ---------------------------------------------------------------------- |
| `data`       | Object    | Berisi access token, informasi masa berlaku token, dan informasi user. |
| `message`    | String    | Pesan yang menjelaskan hasil proses login.                             |
| `statusCode` | Integer   | HTTP status code dari hasil proses.                                    |

---

# 4. Authentication Provider

Endpoint ini digunakan untuk memvalidasi `id_token` yang diberikan oleh provider autentikasi pihak ketiga (contoh: Google). Endpoint ini akan menentukan apakah user yang login melalui provider tersebut sudah terdaftar di sistem atau belum.

Apabila email pada `id_token` **belum terdaftar**, maka user akan diarahkan untuk melengkapi data profil melalui endpoint **Register menggunakan OAuth** (lihat bagian 5). Apabila email **sudah terdaftar**, maka user akan otomatis login dan mendapatkan `access_token`.

### Endpoint

```http
POST /auth/provider
```

### Request Body

```json
{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImFiYzEyMyJ9...",
  "provider": "google"
}
```

### Request Body Parameters

| Key        | Tipe Data | Required | Keterangan                                                                                          |
| ---------- | --------- | -------- | ----------------------------------------------------------------------------------------------------- |
| `id_token` | String    | Ya       | ID Token yang diterima dari provider autentikasi setelah user berhasil login (contoh: Google Sign-In). |
| `provider` | String    | Ya       | Jenis provider yang digunakan untuk autentikasi. Saat ini hanya menerima nilai `google`.               |

### Aturan Validasi

- `id_token` wajib diisi.
- `id_token` harus berupa token yang valid dan belum kedaluwarsa, serta dapat diverifikasi oleh provider terkait.
- `provider` wajib diisi.
- `provider` harus bernilai salah satu dari: `google`.

### Response

Endpoint ini mengembalikan status autentikasi user, yang menentukan apakah user perlu melengkapi profil terlebih dahulu atau langsung berhasil login.

**Contoh response ketika email belum terdaftar (perlu lengkapi profil):**

```json
{
  "data": {
    "email": "user@example.com",
    "name": "Budi Santoso",
    "status": "NEED_COMPLETE_PROFILE",
    "temp_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "Silakan lengkapi profil Anda untuk menyelesaikan proses registrasi.",
  "statusCode": 200
}
```

**Contoh response ketika email sudah terdaftar (login berhasil):**

```json
{
  "data": {
    "email": "user@example.com",
    "name": "Budi Santoso",
    "status": "SUCCESS",
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "Berhasil login.",
  "statusCode": 200
}
```

### Response Data

| Key            | Tipe Data | Keterangan                                                                                                                                                     |
| -------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `email`        | String    | Email user yang didapatkan dari hasil verifikasi `id_token`.                                                                                                   |
| `name`         | String    | Nama user yang didapatkan dari hasil verifikasi `id_token`.                                                                                                     |
| `status`       | String    | Status hasil autentikasi. Bernilai `NEED_COMPLETE_PROFILE` apabila user belum terdaftar dan perlu melengkapi profil, atau `SUCCESS` apabila user berhasil login. |
| `access_token` | String    | JSON Web Token (JWT) yang digunakan sebagai kredensial untuk mengakses endpoint yang membutuhkan autentikasi. Hanya muncul apabila `status` bernilai `SUCCESS`.   |
| `temp_token`   | String    | Token sementara yang wajib dikirimkan pada endpoint **Register menggunakan OAuth**. Hanya muncul apabila `status` bernilai `NEED_COMPLETE_PROFILE`.               |

### Struktur Response

| Key          | Tipe Data | Keterangan                                                     |
| ------------ | --------- | ----------------------------------------------------------------- |
| `data`       | Object    | Berisi status autentikasi beserta token yang relevan.             |
| `message`    | String    | Pesan yang menjelaskan hasil proses autentikasi.                  |
| `statusCode` | Integer   | HTTP status code dari hasil proses.                                |

---

# 5. Register menggunakan OAuth

Endpoint ini digunakan untuk menyelesaikan proses registrasi user yang sebelumnya login menggunakan provider (Google) melalui endpoint **Authentication Provider**, namun belum terdaftar di sistem (`status: NEED_COMPLETE_PROFILE`). User wajib mengirimkan `temp_token` yang didapatkan dari endpoint tersebut beserta data profil tambahan yang belum tersedia dari provider.

### Endpoint

```http
POST /auth/register/oauth
```

### Request Body

```json
{
  "name": "Budi Santoso",
  "temp_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "phoneNumber": "081234567890",
  "date_of_birth": "2000-05-15T00:00:00Z",
  "gender": "male"
}
```

### Request Body Parameters

| Key             | Tipe Data              | Required | Keterangan                                                                                                                      |
| --------------- | ---------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `name`          | String                  | Ya       | Nama lengkap user.                                                                                                                |
| `temp_token`    | String                  | Ya       | Token sementara yang didapatkan dari endpoint **Authentication Provider** (`/auth/provider`). Digunakan untuk memvalidasi identitas user yang telah diverifikasi oleh provider. |
| `phoneNumber`   | String                  | Ya       | Nomor telepon user. Harus memiliki panjang antara 9 sampai 15 karakter.                                                            |
| `date_of_birth` | String (ISO 8601 Date)  | Ya       | Tanggal lahir user, dengan format `YYYY-MM-DDTHH:mm:ssZ`.                                                                          |
| `gender`        | String                  | Ya       | Jenis kelamin user. Hanya menerima nilai `male` atau `female`.                                                                     |

### Aturan Validasi

- `name` wajib diisi.
- `temp_token` wajib diisi.
- `temp_token` harus berupa token yang valid, belum kedaluwarsa, dan sesuai dengan token yang diterbitkan pada endpoint `/auth/provider`.
- `phoneNumber` wajib diisi.
- `phoneNumber` harus memiliki panjang minimal 9 karakter dan maksimal 15 karakter.
- `date_of_birth` wajib diisi.
- `gender` wajib diisi.
- `gender` harus bernilai salah satu dari: `male`, `female`.
- Email yang terkait dengan `temp_token` tidak boleh sudah terdaftar pada sistem.

### Response

Endpoint ini mengembalikan data berupa informasi autentikasi user dan access token yang dapat digunakan untuk mengakses endpoint yang membutuhkan autentikasi.

Contoh response ketika registrasi berhasil:

```json
{
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "user_id": "c4e8f131-f41a-4afc-8d8a-02810cafa920",
      "email": "user@example.com",
      "role": "customer"
    }
  },
  "message": "Berhasil melakukan registrasi.",
  "statusCode": 200
}
```

### Response Data

| Key            | Tipe Data | Keterangan                                                                                                    |
| -------------- | --------- | --------------------------------------------------------------------------------------------------------------- |
| `access_token` | String    | JSON Web Token (JWT) yang digunakan sebagai kredensial untuk mengakses endpoint yang membutuhkan autentikasi. |
| `user`         | Object    | Informasi user yang berhasil melakukan registrasi.                                                              |

### User Object

| Key       | Tipe Data | Keterangan                                                                  |
| --------- | --------- | ----------------------------------------------------------------------------- |
| `user_id` | String    | ID unik user yang berhasil melakukan registrasi.                              |
| `email`   | String    | Email user yang didapatkan dari hasil verifikasi provider.                    |
| `role`    | String    | Role user dalam sistem, seperti `customer`, `kasir`, `admin`, atau `owner`.  |

### Struktur Response

| Key          | Tipe Data | Keterangan                                                             |
| ------------ | --------- | ----------------------------------------------------------------------- |
| `data`       | Object    | Berisi access token dan informasi user.                                |
| `message`    | String    | Pesan yang menjelaskan hasil proses registrasi.                        |
| `statusCode` | Integer   | HTTP status code dari hasil proses.                                    |

---

# API Summary

| Method | Endpoint                    | Fungsi                                                                                              |
| ------ | ---------------------------- | ----------------------------------------------------------------------------------------------------- |
| POST   | `/auth/register/credential`  | Mendaftarkan user menggunakan credential/email dan mengirimkan OTP.                                   |
| POST   | `/auth/verify-credential`    | Memverifikasi akun menggunakan OTP yang diterima melalui email.                                       |
| POST   | `/auth/login/credential`     | Melakukan login user menggunakan email dan password untuk seluruh role yang tersedia.                 |
| POST   | `/auth/provider`              | Memvalidasi `id_token` dari provider (Google) untuk menentukan apakah user perlu login atau registrasi. |
| POST   | `/auth/register/oauth`        | Menyelesaikan proses registrasi user baru yang login melalui provider, menggunakan `temp_token`.       |---

# Quick Start

Urutan menjalankan backend dari awal:

### 1. Konfigurasi environment

Buat file `.env` berdasarkan `.env.example`.

### 2. Jalankan migration

```bash
go run cmd/migrate/main.go up
```

### 3. Masukkan dummy data (opsional)

```bash
go run cmd/seed/main.go up
```

### 4. Jalankan backend

```bash
go run main.go
```

Backend siap digunakan setelah aplikasi berhasil dijalankan.
