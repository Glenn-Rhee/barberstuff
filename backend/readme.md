# Backend API Documentation

Backend aplikasi ini dibangun menggunakan bahasa pemrograman Go (Golang).

## 1. Setup Environment

Sebelum menjalankan backend, buat file `.env` berdasarkan file `.env.example`.

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

| Key     | Tipe Data | Keterangan                         |
| ------- | --------- | ---------------------------------- |
| `id`    | String    | ID unik user.                      |
| `email` | String    | Email user yang telah didaftarkan. |

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

Endpoint ini digunakan untuk melakukan verifikasi kode OTP. Endpoint ini bersifat umum dan dipakai pada dua alur berbeda, yang dibedakan otomatis oleh sistem berdasarkan status verifikasi akun (`user_id`) yang dikirimkan:

- **Verifikasi akun baru** — dipakai setelah proses **Credential Register** (bagian 1), untuk mengaktifkan akun yang baru didaftarkan.
- **Verifikasi lupa password** — dipakai setelah proses **Forgot Password** (bagian 4), untuk membuktikan bahwa permintaan reset password berasal dari pemilik akun sebelum melanjutkan ke endpoint **Reset Password** (bagian 5).

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

Isi `data` pada endpoint ini berbeda tergantung alur yang sedang dijalankan.

**Contoh response ketika verifikasi akun baru berhasil** (alur Credential Register):

```json
{
  "data": {},
  "message": "Berhasil verifikasi akun! Silahkan login.",
  "statusCode": 200
}
```

**Contoh response ketika verifikasi lupa password berhasil** (alur Forgot Password):

```json
{
  "data": {
    "reset_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "OTP berhasil diverifikasi. Silakan lanjutkan proses reset password.",
  "statusCode": 200
}
```

Struktur response:

| Key          | Tipe Data | Keterangan                                                                                             |
| ------------ | --------- | ------------------------------------------------------------------------------------------------------ |
| `data`       | Object    | Bernilai `{}` pada alur verifikasi akun baru. Berisi `reset_token` pada alur verifikasi lupa password. |
| `message`    | String    | Pesan yang menjelaskan hasil verifikasi.                                                               |
| `statusCode` | Integer   | HTTP status code dari hasil proses.                                                                    |

### Response Data (alur Forgot Password)

| Key           | Tipe Data | Keterangan                                                                                                                         |
| ------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `reset_token` | String    | Token sementara, berlaku singkat, yang wajib dikirimkan pada endpoint **Reset Password** (`/auth/reset`) untuk mengganti password. |

### Response Gagal

Beberapa contoh pesan kegagalan yang mungkin dikembalikan:

```json
{
  "data": null,
  "message": "OTP tidak valid, silahkan coba lagi. Sisa percobaan 3 kali",
  "statusCode": 400
}
```

```json
{
  "data": null,
  "message": "Anda telah melakukan kesalahan 5 kali percobaan! Mohon untuk kirim ulang OTP!",
  "statusCode": 400
}
```

```json
{
  "data": null,
  "message": "OTP sudah kedaluwarsa. Mohon kirim ulang OTP!",
  "statusCode": 400
}
```

---

## 3. Credential Login

Endpoint ini digunakan untuk melakukan login user menggunakan email dan password. Endpoint ini bersifat umum dan dapat digunakan oleh seluruh role pengguna, yaitu customer, kasir, admin, maupun mitra.

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
| `role`    | String    | Role user dalam sistem, seperti `customer`, `kasir`, `admin`, atau `mitra`. |

### Struktur Response

| Key          | Tipe Data | Keterangan                                                             |
| ------------ | --------- | ---------------------------------------------------------------------- |
| `data`       | Object    | Berisi access token, informasi masa berlaku token, dan informasi user. |
| `message`    | String    | Pesan yang menjelaskan hasil proses login.                             |
| `statusCode` | Integer   | HTTP status code dari hasil proses.                                    |

---

## 4. Forgot Password

Endpoint ini digunakan untuk memulai proses lupa password. Sistem akan mengirimkan kode OTP ke email pengguna yang wajib diverifikasi terlebih dahulu melalui endpoint **Verify Credential / OTP** (bagian 2) sebelum pengguna dapat mengganti password melalui endpoint **Reset Password** (bagian 5).

Endpoint ini hanya dapat digunakan oleh akun yang sudah terverifikasi dan login menggunakan email/password (bukan akun yang login melalui Google/OAuth).

### Endpoint

```http
POST /auth/forgot
```

### Request Body

```json
{
  "email": "user@example.com"
}
```

### Request Body Parameters

| Key     | Tipe Data | Required | Keterangan                                                    |
| ------- | --------- | -------- | ------------------------------------------------------------- |
| `email` | String    | Ya       | Email akun yang terdaftar dan ingin melakukan reset password. |

### Aturan Validasi

- `email` wajib diisi dan harus memiliki format email yang valid.
- `email` harus terdaftar pada sistem.
- Akun terkait `email` harus sudah terverifikasi (`is_verified = true`).
- Akun terkait `email` tidak boleh menggunakan `login_type` OAuth/Google.
- Permintaan OTP untuk `email` yang sama dibatasi 1 kali setiap periode kedaluwarsa OTP untuk mencegah penyalahgunaan (spam).

### Response Sukses

Jika permintaan berhasil, OTP dikirimkan ke email pengguna dan `user_id` dikembalikan untuk digunakan pada endpoint **Verify Credential / OTP**.

```json
{
  "data": {
    "user_id": "c4e8f131-f41a-4afc-8d8a-02810cafa920"
  },
  "message": "OTP telah dikirim ke email Anda. Silakan periksa kotak masuk atau spam.",
  "statusCode": 200
}
```

### Response Data

| Key       | Tipe Data | Keterangan                                                                           |
| --------- | --------- | ------------------------------------------------------------------------------------ |
| `user_id` | String    | ID unik user, wajib dikirimkan pada endpoint **Verify Credential / OTP** berikutnya. |

### Response Gagal

Beberapa contoh pesan kegagalan yang mungkin dikembalikan:

```json
{
  "data": null,
  "message": "Email tidak terdaftar!",
  "statusCode": 404
}
```

```json
{
  "data": null,
  "message": "Email belum verified! Tidak dapat reset password.",
  "statusCode": 400
}
```

```json
{
  "data": null,
  "message": "Email Anda login dengan google! Tidak dapat reset password.",
  "statusCode": 400
}
```

```json
{
  "data": null,
  "message": "Terlalu banyak percobaan, coba lagi nanti.",
  "statusCode": 429
}
```

---

## 5. Reset Password

Endpoint ini digunakan untuk mengganti password akun setelah kode OTP berhasil diverifikasi pada endpoint **Verify Credential / OTP** (bagian 2). Endpoint ini wajib menggunakan `reset_token` yang didapatkan dari hasil verifikasi OTP tersebut.

### Endpoint

```http
POST /auth/reset
```

### Request Body

```json
{
  "reset_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "new_password": "NewSecurePass123"
}
```

### Request Body Parameters

| Key            | Tipe Data | Required | Keterangan                                                                               |
| -------------- | --------- | -------- | ---------------------------------------------------------------------------------------- |
| `reset_token`  | String    | Ya       | Token yang didapatkan dari hasil verifikasi OTP pada endpoint `/auth/verify-credential`. |
| `new_password` | String    | Ya       | Password baru untuk akun, minimal 5 karakter.                                            |

### Aturan Validasi

- `reset_token` wajib diisi.
- `reset_token` harus berupa token yang valid, belum kedaluwarsa, dan belum pernah dipakai sebelumnya.
- `new_password` wajib diisi dan memiliki panjang minimal 5 karakter.

### Response Sukses

```json
{
  "data": null,
  "message": "Password berhasil direset. Silahkan login menggunakan password baru.",
  "statusCode": 200
}
```

### Response Gagal

```json
{
  "data": null,
  "message": "Token tidak valid atau sudah kedaluwarsa.",
  "statusCode": 400
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat reset password!",
  "statusCode": 406
}
```

---

## 6. Authentication Provider

Endpoint ini digunakan untuk memvalidasi `id_token` yang diberikan oleh provider autentikasi pihak ketiga (contoh: Google). Endpoint ini akan menentukan apakah user yang login melalui provider tersebut sudah terdaftar di sistem atau belum.

Apabila email pada `id_token` **belum terdaftar**, maka user akan diarahkan untuk melengkapi data profil melalui endpoint **Register menggunakan OAuth** (lihat bagian 7). Apabila email **sudah terdaftar**, maka user akan otomatis login dan mendapatkan `access_token`.

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

| Key        | Tipe Data | Required | Keterangan                                                                                             |
| ---------- | --------- | -------- | ------------------------------------------------------------------------------------------------------ |
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

| Key            | Tipe Data | Keterangan                                                                                                                                                       |
| -------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `email`        | String    | Email user yang didapatkan dari hasil verifikasi `id_token`.                                                                                                     |
| `name`         | String    | Nama user yang didapatkan dari hasil verifikasi `id_token`.                                                                                                      |
| `status`       | String    | Status hasil autentikasi. Bernilai `NEED_COMPLETE_PROFILE` apabila user belum terdaftar dan perlu melengkapi profil, atau `SUCCESS` apabila user berhasil login. |
| `access_token` | String    | JSON Web Token (JWT) yang digunakan sebagai kredensial untuk mengakses endpoint yang membutuhkan autentikasi. Hanya muncul apabila `status` bernilai `SUCCESS`.  |
| `temp_token`   | String    | Token sementara yang wajib dikirimkan pada endpoint **Register menggunakan OAuth**. Hanya muncul apabila `status` bernilai `NEED_COMPLETE_PROFILE`.              |

### Struktur Response

| Key          | Tipe Data | Keterangan                                            |
| ------------ | --------- | ----------------------------------------------------- |
| `data`       | Object    | Berisi status autentikasi beserta token yang relevan. |
| `message`    | String    | Pesan yang menjelaskan hasil proses autentikasi.      |
| `statusCode` | Integer   | HTTP status code dari hasil proses.                   |

---

## 7. Register menggunakan OAuth

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

| Key             | Tipe Data              | Required | Keterangan                                                                                                                                                                      |
| --------------- | ---------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`          | String                 | Ya       | Nama lengkap user.                                                                                                                                                              |
| `temp_token`    | String                 | Ya       | Token sementara yang didapatkan dari endpoint **Authentication Provider** (`/auth/provider`). Digunakan untuk memvalidasi identitas user yang telah diverifikasi oleh provider. |
| `phoneNumber`   | String                 | Ya       | Nomor telepon user. Harus memiliki panjang antara 9 sampai 15 karakter.                                                                                                         |
| `date_of_birth` | String (ISO 8601 Date) | Ya       | Tanggal lahir user, dengan format `YYYY-MM-DDTHH:mm:ssZ`.                                                                                                                       |
| `gender`        | String                 | Ya       | Jenis kelamin user. Hanya menerima nilai `male` atau `female`.                                                                                                                  |

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
| -------------- | --------- | ------------------------------------------------------------------------------------------------------------- |
| `access_token` | String    | JSON Web Token (JWT) yang digunakan sebagai kredensial untuk mengakses endpoint yang membutuhkan autentikasi. |
| `user`         | Object    | Informasi user yang berhasil melakukan registrasi.                                                            |

### User Object

| Key       | Tipe Data | Keterangan                                                                  |
| --------- | --------- | --------------------------------------------------------------------------- |
| `user_id` | String    | ID unik user yang berhasil melakukan registrasi.                            |
| `email`   | String    | Email user yang didapatkan dari hasil verifikasi provider.                  |
| `role`    | String    | Role user dalam sistem, seperti `customer`, `kasir`, `admin`, atau `mitra`. |

### Struktur Response

| Key          | Tipe Data | Keterangan                                      |
| ------------ | --------- | ----------------------------------------------- |
| `data`       | Object    | Berisi access token dan informasi user.         |
| `message`    | String    | Pesan yang menjelaskan hasil proses registrasi. |
| `statusCode` | Integer   | HTTP status code dari hasil proses.             |

---

## 8. Register Admin

Endpoint ini digunakan untuk membuat akun admin secara **internal**. Endpoint ini **tidak diperuntukkan untuk diakses melalui UI/frontend**, melainkan hanya dapat diakses melalui API tools seperti Postman atau semacamnya, dengan menyertakan `secret-key` pada header request.

Endpoint ini umumnya digunakan sekali di awal (initial setup) untuk membuat akun admin pertama pada sistem.

### Endpoint

```http
POST /auth/register/admin
```

### Headers

| Key          | Required | Keterangan                                                                 |
| ------------ | -------- | --------------------------------------------------------------------------- |
| `secret-key` | Ya       | Secret key internal yang digunakan untuk otorisasi pembuatan akun admin.    |

### Request Body

```json
{
  "name": "Admin Utama",
  "email": "admin@example.com",
  "password": "SecurePass123"
}
```

### Request Body Parameters

| Key        | Tipe Data | Required | Keterangan                                             |
| ---------- | --------- | -------- | ------------------------------------------------------- |
| `name`     | String    | Ya       | Nama lengkap admin.                                      |
| `email`    | String    | Ya       | Alamat email admin dengan format email yang valid.       |
| `password` | String    | Ya       | Password admin, minimal 5 karakter.                      |

### Aturan Validasi

- `name` wajib diisi.
- `email` wajib diisi dan harus memiliki format email yang valid.
- `password` wajib diisi dan memiliki panjang minimal 5 karakter.
- Header `secret-key` wajib disertakan dan harus sesuai dengan secret key yang terdaftar pada sistem.
- Akun admin hanya dapat didaftarkan satu kali; apabila akun admin sudah pernah terdaftar sebelumnya, permintaan akan ditolak.

### Response Sukses

```json
{
  "data": null,
  "message": "Berhasil membuat akun admin",
  "statusCode": 201
}
```

Pada response sukses:

- `data` bernilai `null` karena endpoint ini tidak mengembalikan data user maupun token.
- `message` berisi konfirmasi bahwa akun admin berhasil dibuat.
- `statusCode` bernilai `201`.

### Response Gagal

Contoh response ketika akun admin sudah pernah terdaftar sebelumnya:

```json
{
  "data": null,
  "message": "Akun admin telah terdaftar! Tidak dapat mendaftar kembali",
  "statusCode": 400
}
```

Pada response gagal:

- `data` bernilai `null` karena tidak ada data yang dikembalikan.
- `message` berisi informasi mengenai penyebab kegagalan.
- `statusCode` bernilai `400` (atau kode error lain sesuai jenis kesalahan, misalnya `401`/`403` apabila `secret-key` tidak valid).

### Catatan

- Endpoint ini **tidak boleh** diekspos atau dipanggil dari sisi client/UI aplikasi, karena bersifat sensitif dan hanya untuk keperluan internal.
- Pastikan `secret-key` disimpan secara aman (misalnya melalui environment variable) dan tidak dibagikan ke pihak yang tidak berwenang.

---

## 9. Create Store

Endpoint ini digunakan untuk membuat data toko/cabang (store) baru. Endpoint ini hanya dapat diakses oleh user dengan role **admin**.

### Endpoint

```http
POST /store
```

### Headers

| Key             | Required | Keterangan                                                                                  |
| --------------- | -------- | ---------------------------------------------------------------------------------------------- |
| `Authorization` | Ya       | Access token milik admin, dengan format `Bearer <token>`.                                       |

### Request Body

```json
{
  "name": "Toko Cabang Kemang",
  "description": "Cabang baru di area Kemang, Jakarta Selatan.",
  "alamat": "Jl. Kemang Raya No. 10, Jakarta Selatan",
  "banner_url": "https://example.com/images/banner-kemang.jpg",
  "open_hour": "2024-01-01T08:00:00Z",
  "close_hour": "2024-01-01T21:00:00Z",
  "lat": -6.260278,
  "long": 106.813889,
  "phone_number": "081234567890"
}
```

### Request Body Parameters

| Key            | Tipe Data     | Required | Keterangan                                                                              |
| -------------- | ------------- | -------- | ------------------------------------------------------------------------------------------ |
| `name`         | String        | Ya       | Nama toko/cabang.                                                                            |
| `description`  | String        | Tidak    | Deskripsi toko/cabang. Boleh bernilai `null`.                                                |
| `alamat`       | String        | Ya       | Alamat lengkap toko/cabang.                                                                   |
| `banner_url`   | String        | Ya       | URL gambar banner toko. Harus berupa format URL yang valid.                                  |
| `open_hour`    | Date/DateTime | Ya       | Jam buka toko dalam format ISO 8601.                                                          |
| `close_hour`   | Date/DateTime | Ya       | Jam tutup toko dalam format ISO 8601.                                                         |
| `lat`          | Float         | Ya       | Koordinat latitude lokasi toko.                                                               |
| `long`         | Float         | Ya       | Koordinat longitude lokasi toko.                                                              |
| `phone_number` | String        | Ya       | Nomor telepon toko, minimal 9 dan maksimal 15 karakter.                                      |

### Aturan Validasi

- Header `Authorization` wajib disertakan dengan format `Bearer <token>`, dan token harus milik user dengan role `admin`.
- `name` wajib diisi.
- `description` bersifat opsional dan boleh tidak disertakan atau bernilai `null`.
- `alamat` wajib diisi.
- `banner_url` wajib diisi dan harus berupa URL yang valid.
- `open_hour` wajib diisi.
- `close_hour` wajib diisi.
- `lat` wajib diisi.
- `long` wajib diisi.
- `phone_number` wajib diisi, dengan panjang minimal 9 karakter dan maksimal 15 karakter.

### Response Sukses

```json
{
  "data": null,
  "message": "Berhasil membuat toko cabang baru!",
  "statusCode": 200
}
```

Pada response sukses:

- `data` bernilai `null` karena endpoint ini tidak mengembalikan data toko yang baru dibuat.
- `message` berisi konfirmasi bahwa toko cabang baru berhasil dibuat.
- `statusCode` bernilai `200`.

### Response Gagal

Beberapa contoh pesan kegagalan yang mungkin dikembalikan:

```json
{
  "data": null,
  "message": "Anda tidak memiliki akses untuk membuat toko cabang baru!",
  "statusCode": 403
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat membuat toko cabang baru!",
  "statusCode": 406
}
```

---

## 10. Get All Stores

Endpoint ini digunakan untuk mendapatkan seluruh data store/cabang yang tersedia pada sistem.

### Endpoint

```http
GET /store
```

### Headers

| Key             | Required | Keterangan                                                 |
| --------------- | -------- | ------------------------------------------------------------- |
| `Authorization` | Ya       | Access token yang valid, dengan format `Bearer <token>`.       |

### Response Sukses

```json
{
  "data": [
    {
      "id": "51c45423-5f2a-4067-b8c9-5a2513059ea1",
      "name": "Barberstuff Cabang Pondok Gede",
      "phone_number": "081234567890",
      "coordinate": "-6.260278,106.813889",
      "open_hour": "2026-08-31T09:00:00Z",
      "close_hour": "2026-08-31T21:00:00Z",
      "banner_url": "https://example.com/images/store-kemang-banner.jpg",
      "address": "Jl. Kemang Raya No. 45, Jakarta Selatan",
      "description": "Cabang baru di kawasan Kemang, Jakarta Selatan",
      "created_at": "2026-09-01T07:24:12.256445Z"
    }
  ],
  "message": "Succes get data stores!",
  "statusCode": 200
}
```

### Struktur `data` (Array of Store Object)

| Key            | Tipe Data     | Keterangan                                                    |
| -------------- | ------------- | ------------------------------------------------------------- |
| `id`           | String (UUID) | ID unik store.                                                  |
| `name`         | String        | Nama store/cabang.                                              |
| `phone_number` | String        | Nomor telepon store.                                             |
| `coordinate`   | String        | Koordinat lokasi store dalam format `"latitude,longitude"`.      |
| `open_hour`    | Date/DateTime | Jam buka store dalam format ISO 8601.                            |
| `close_hour`   | Date/DateTime | Jam tutup store dalam format ISO 8601.                           |
| `banner_url`   | String        | URL gambar banner store.                                         |
| `address`      | String        | Alamat lengkap store.                                            |
| `description`  | String        | Deskripsi store.                                                 |
| `created_at`   | Date/DateTime | Waktu store dibuat, dalam format ISO 8601.                       |

### Response Gagal

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat mengambil data stores!",
  "statusCode": 406
}
```

---

## 11. Get Store Detail

Endpoint ini digunakan untuk mendapatkan detail satu store/cabang berdasarkan `id`, termasuk daftar service, package, rating & review, serta capster yang tersedia pada store tersebut.

### Endpoint

```http
GET /store/:id
```

### Path Parameters

| Key  | Tipe Data     | Required | Keterangan             |
| ---- | ------------- | -------- | ----------------------- |
| `id` | String (UUID) | Ya       | ID unik store yang dituju. |

### Headers

| Key             | Required | Keterangan                                                 |
| --------------- | -------- | ------------------------------------------------------------- |
| `Authorization` | Ya       | Access token yang valid, dengan format `Bearer <token>`.       |

### Response Sukses

```json
{
  "data": {
    "store": {
      "id": "51c45423-5f2a-4067-b8c9-5a2513059ea1",
      "name": "Barberstuff Cabang Pondok Gede",
      "phone_number": "081234567890",
      "coordinate": "-6.260278,106.813889",
      "open_hour": "2026-08-31T09:00:00Z",
      "close_hour": "2026-08-31T21:00:00Z",
      "banner_url": "https://example.com/images/store-kemang-banner.jpg",
      "address": "Jl. Kemang Raya No. 45, Jakarta Selatan",
      "description": "Cabang baru di kawasan Kemang, Jakarta Selatan",
      "created_at": "2026-09-01T07:24:12.256445Z"
    },
    "service": [
      {
        "id": "8c1e2a3b-1234-4a5b-9c6d-7e8f9a0b1c2d",
        "name": "Haircut",
        "price": "50000",
        "duration_minutes": 30,
        "do_dont": "Datang 10 menit sebelum jadwal.",
        "description": "Potong rambut standar.",
        "status": "active"
      }
    ],
    "package": [
      {
        "id": "9d2f3b4c-2345-4b6c-8d7e-9f0a1b2c3d4e",
        "name": "Haircut + Shaving",
        "price": "80000",
        "duration_minutes": 60,
        "do_dont": "Datang 10 menit sebelum jadwal.",
        "description": "Paket potong rambut dan cukur.",
        "status": "active"
      }
    ],
    "rating": {
      "avg_rating": 4.5,
      "review": [
        {
          "id": "1a2b3c4d-3456-4c7d-9e8f-0a1b2c3d4e5f",
          "message": "Pelayanan ramah dan hasil rapi.",
          "rating": 5,
          "user": {
            "id": "2b3c4d5e-4567-4d8e-0f1a-2b3c4d5e6f7a",
            "name": "Budi Santoso",
            "image_url": "https://example.com/images/user-budi.jpg",
            "premium_type": "bestie"
          }
        }
      ]
    },
    "capster": [
      {
        "id": "3c4d5e6f-5678-4e9f-1a2b-3c4d5e6f7a8b",
        "name": "Andi Wijaya",
        "title": "Senior Capster",
        "status": "active",
        "image_url": "https://example.com/images/capster-andi.jpg",
        "avg_rating": 4.8
      }
    ]
  },
  "message": "Succes get store detail!",
  "statusCode": 200
}
```

### Struktur `data`

| Key       | Tipe Data | Keterangan                                                    |
| --------- | --------- | --------------------------------------------------------------- |
| `store`   | Object    | Informasi detail store (lihat struktur pada bagian **Get All Stores**). |
| `service` | Array     | Daftar service yang tersedia pada store tersebut.                 |
| `package` | Array     | Daftar package yang tersedia pada store tersebut.                 |
| `rating`  | Object    | Rating rata-rata beserta daftar review store tersebut.            |
| `capster` | Array     | Daftar capster yang bertugas pada store tersebut.                 |

### Struktur `service` (Array of Service Object)

| Key                 | Tipe Data          | Keterangan                                                                |
| ------------------- | ------------------ | -------------------------------------------------------------------------- |
| `id`                | String (UUID)      | ID unik service.                                                             |
| `name`              | String             | Nama service.                                                                |
| `price`             | String/Decimal     | Harga service.                                                               |
| `duration_minutes`  | Integer            | Estimasi durasi pengerjaan service (dalam menit). Dapat bernilai `null`.       |
| `do_dont`           | String             | Catatan hal yang boleh/tidak boleh dilakukan terkait service. Dapat bernilai `null`. |
| `description`       | String             | Deskripsi service. Dapat bernilai `null`.                                     |
| `status`            | String              | Status service. Bernilai `active` atau `inactive`.                            |

### Struktur `package` (Array of Package Object)

| Key                 | Tipe Data          | Keterangan                                                                |
| ------------------- | ------------------ | -------------------------------------------------------------------------- |
| `id`                | String (UUID)      | ID unik package.                                                             |
| `name`              | String             | Nama package.                                                                |
| `price`             | String/Decimal     | Harga package.                                                               |
| `duration_minutes`  | Integer            | Estimasi durasi pengerjaan package (dalam menit). Dapat bernilai `null`.       |
| `do_dont`           | String             | Catatan hal yang boleh/tidak boleh dilakukan terkait package. Dapat bernilai `null`. |
| `description`       | String             | Deskripsi package. Dapat bernilai `null`.                                     |
| `status`            | String              | Status package. Bernilai `active` atau `inactive`.                            |

### Struktur `rating`

| Key          | Tipe Data | Keterangan                                  |
| ------------ | --------- | ---------------------------------------------- |
| `avg_rating` | Float     | Rata-rata rating store berdasarkan seluruh review. |
| `review`     | Array     | Daftar review yang diberikan oleh customer.        |

### Struktur `review` (Array of Review Object)

| Key       | Tipe Data     | Keterangan                                 |
| --------- | ------------- | --------------------------------------------- |
| `id`      | String (UUID) | ID unik review.                                 |
| `message` | String        | Isi pesan/ulasan dari customer.                 |
| `rating`  | Integer       | Nilai rating yang diberikan oleh customer.       |
| `user`    | Object        | Informasi customer pemberi review (lihat struktur `user` di bawah). |

### Struktur `user` (pada Review)

| Key            | Tipe Data     | Keterangan                                                                       |
| -------------- | ------------- | ----------------------------------------------------------------------------------- |
| `id`           | String (UUID) | ID unik customer.                                                                      |
| `name`         | String        | Nama customer.                                                                         |
| `image_url`    | String        | URL foto profil customer.                                                              |
| `premium_type` | String        | Tipe keanggotaan premium customer. Bernilai salah satu dari: `newbie`, `bestie`, `royal`, `crazy`. |

### Struktur `capster` (Array of Capster Object)

| Key          | Tipe Data     | Keterangan                                           |
| ------------ | ------------- | ------------------------------------------------------- |
| `id`         | String (UUID) | ID unik capster.                                           |
| `name`       | String        | Nama capster.                                              |
| `title`      | String        | Jabatan/gelar capster (contoh: `Senior Capster`).           |
| `status`     | String        | Status capster. Bernilai `active` atau `inactive`.          |
| `image_url`  | String        | URL foto profil capster.                                    |
| `avg_rating` | Float         | Rata-rata rating capster berdasarkan seluruh review.         |

### Response Gagal

Beberapa contoh pesan kegagalan yang mungkin dikembalikan:

```json
{
  "data": null,
  "message": "Store tidak ditemukan!",
  "statusCode": 404
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat mengambil data store!",
  "statusCode": 406
}
```

---
## 12. Update Store
 
Endpoint ini digunakan untuk mengupdate seluruh data store/cabang berdasarkan `id`, apabila diperlukan. Header yang wajib disertakan sama seperti endpoint lain yang membutuhkan autentikasi.
 
### Endpoint
 
```http
PUT /store/:id
```
 
### Path Parameters
 
| Key  | Tipe Data     | Required | Keterangan                |
| ---- | ------------- | -------- | --------------------------- |
| `id` | String (UUID) | Ya       | ID unik store yang akan diupdate. |
 
### Headers
 
| Key             | Required | Keterangan                                                 |
| --------------- | -------- | ------------------------------------------------------------- |
| `Authorization` | Ya       | Access token yang valid, dengan format `Bearer <token>`.       |
 
### Request Body
 
```json
{
  "name": "Toko Cabang Kemang",
  "description": "Cabang baru di area Kemang, Jakarta Selatan.",
  "address": "Jl. Kemang Raya No. 10, Jakarta Selatan",
  "banner_url": "https://example.com/images/banner-kemang.jpg",
  "open_hour": "2024-01-01T08:00:00Z",
  "close_hour": "2024-01-01T21:00:00Z",
  "lat": -6.260278,
  "long": 106.813889,
  "phone_number": "081234567890",
  "status": "open"
}
```
 
### Request Body Parameters
 
| Key            | Tipe Data     | Required | Keterangan                                                                              |
| -------------- | ------------- | -------- | ------------------------------------------------------------------------------------------ |
| `name`         | String        | Ya       | Nama toko/cabang.                                                                            |
| `description`  | String        | Tidak    | Deskripsi toko/cabang. Boleh bernilai `null`.                                                |
| `address`      | String        | Ya       | Alamat lengkap toko/cabang.                                                                   |
| `banner_url`   | String        | Ya       | URL gambar banner toko. Harus berupa format URL yang valid.                                  |
| `open_hour`    | Date/DateTime | Ya       | Jam buka toko dalam format ISO 8601.                                                          |
| `close_hour`   | Date/DateTime | Ya       | Jam tutup toko dalam format ISO 8601.                                                         |
| `lat`          | Float         | Ya       | Koordinat latitude lokasi toko.                                                               |
| `long`         | Float         | Ya       | Koordinat longitude lokasi toko.                                                              |
| `phone_number` | String        | Ya       | Nomor telepon toko, minimal 9 dan maksimal 15 karakter.                                      |
| `status`       | String        | Ya       | Status toko. Hanya menerima nilai `open` atau `close`.                                       |
 
### Aturan Validasi
 
- Header `Authorization` wajib disertakan dengan format `Bearer <token>`.
- `name` wajib diisi.
- `description` bersifat opsional dan boleh tidak disertakan atau bernilai `null`.
- `address` wajib diisi.
- `banner_url` wajib diisi dan harus berupa URL yang valid.
- `open_hour` wajib diisi.
- `close_hour` wajib diisi.
- `lat` wajib diisi.
- `long` wajib diisi.
- `phone_number` wajib diisi, dengan panjang minimal 9 karakter dan maksimal 15 karakter.
- `status` wajib diisi dan hanya menerima nilai `open` atau `close`.
### Response Sukses
 
```json
{
  "data": null,
  "message": "Berhasil mengubah toko cabang!",
  "statusCode": 200
}
```
 
Pada response sukses:
 
- `data` bernilai `null` karena endpoint ini tidak mengembalikan data toko yang telah diupdate.
- `message` berisi konfirmasi bahwa data toko cabang berhasil diubah.
- `statusCode` bernilai `200`.
### Response Gagal
 
```json
{
  "data": null,
  "message": "Store tidak ditemukan!",
  "statusCode": 404
}
```
 
```json
{
  "data": null,
  "message": "Terjadi kesalahan saat mengubah toko cabang!",
  "statusCode": 406
}
```
 
---
 
# API Summary
 
| Method | Endpoint                    | Fungsi                                                                                                    |
| ------ | ---------------------------- | ----------------------------------------------------------------------------------------------------------- |
| POST   | `/auth/register/credential`  | Mendaftarkan user menggunakan credential/email dan mengirimkan OTP.                                          |
| POST   | `/auth/verify-credential`    | Memverifikasi kode OTP, baik untuk alur verifikasi akun baru maupun alur lupa password.                      |
| POST   | `/auth/login/credential`     | Melakukan login user menggunakan email dan password untuk seluruh role yang tersedia.                        |
| POST   | `/auth/forgot`               | Memulai proses lupa password dan mengirimkan OTP ke email pengguna.                                           |
| POST   | `/auth/reset`                | Mengganti password akun menggunakan `reset_token` hasil verifikasi OTP.                                       |
| POST   | `/auth/provider`             | Memvalidasi `id_token` dari provider (Google) untuk menentukan apakah user perlu login atau registrasi.       |
| POST   | `/auth/register/oauth`       | Menyelesaikan proses registrasi user baru yang login melalui provider, menggunakan `temp_token`.              |
| POST   | `/auth/register/admin`       | Membuat akun admin secara internal (khusus API tools, wajib menyertakan header `secret-key`, tidak untuk UI). |
| POST   | `/store`                     | Membuat data toko/cabang baru. Hanya dapat diakses oleh token milik admin.                                    |
| GET    | `/store`                     | Mendapatkan seluruh data store/cabang yang tersedia.                                                           |
| GET    | `/store/:id`                 | Mendapatkan detail satu store/cabang beserta service, package, rating, dan capster-nya.                        |
| PUT    | `/store/:id`                 | Mengupdate seluruh data store/cabang berdasarkan `id`.    