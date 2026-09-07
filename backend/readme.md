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
type StatusResponse string

const (
    StatusSuccess StatusResponse = "success"
    StatusFailed  StatusResponse = "failed"
)

type ResponseApi[T any] struct {
    Data       T              `json:"data"`
    Message    string         `json:"message"`
    StatusCode int            `json:"statusCode"`
    Status     StatusResponse `json:"status"`
}
```

| Key | Tipe Data | Keterangan |
| --- | --- | --- |
| `data` | Object / Array / null | Data yang dikembalikan oleh API. Tipe datanya dapat berbeda tergantung endpoint. |
| `message` | String | Pesan yang menjelaskan hasil proses API. |
| `statusCode` | Integer | HTTP status code yang menunjukkan hasil proses request. |
| `status` | String | Status hasil proses API. Bernilai `success` atau `failed`. |

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
  "password": "SecurePass123",
  "image_url": "https://i.pinimg.com/736x/98/d0/f6/98d0f6039d5aadb7abfc8c3b07fcc60d.jpg"
}
```

### Request Body Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `name` | String | Ya | Nama lengkap pengguna. |
| `phoneNumber` | String | Ya | Nomor telepon pengguna, minimal 9 dan maksimal 15 karakter. |
| `date_of_birth` | Date/DateTime | Ya | Tanggal lahir pengguna dalam format ISO 8601. |
| `gender` | String | Ya | Jenis kelamin pengguna. Nilai yang diperbolehkan: `male` atau `female`. |
| `email` | String | Ya | Alamat email pengguna dengan format email yang valid. |
| `password` | String | Ya | Password pengguna, minimal 5 karakter. |
| `image_url` | String | Tidak | Url untuk upload gambar user |

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

```json
{
  "data": {
    "id": "633dc6e5-89e3-487d-8e9b-86cc23b71799",
    "email": "aaa@gmail.com"
  },
  "message": "OTP telah dikirim ke email Anda. Silakan periksa kotak masuk atau spam.",
  "statusCode": 200,
  "status": "success"
}
```

### Response Gagal

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat mendaftar. Silahkan coba lagi nanti!",
  "statusCode": 406,
  "status": "failed"
}
```

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

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `user_id` | String | Ya | ID unik user yang akan diverifikasi. |
| `otp` | String | Ya | Kode OTP yang diterima melalui email. OTP harus terdiri dari tepat 6 digit angka. |

### Aturan Validasi

- `user_id` wajib diisi.
- `otp` wajib diisi.
- `otp` harus memiliki panjang tepat 6 karakter.
- `otp` hanya boleh berisi angka.

### Response Sukses

```json
{
  "data": null,
  "message": "Berhasil.",
  "statusCode": 200,
  "status": "success"
}
```

### Response Gagal

```json
{
  "data": null,
  "message": "OTP tidak valid, silahkan coba lagi. Sisa percobaan 3 kali",
  "statusCode": 400,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Anda telah melakukan kesalahan 5 kali percobaan! Mohon untuk kirim ulang OTP!",
  "statusCode": 400,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "OTP sudah kedaluwarsa. Mohon kirim ulang OTP!",
  "statusCode": 400,
  "status": "failed"
}
```

### Response

Isi `data` pada endpoint ini berbeda tergantung alur yang sedang dijalankan.

**Contoh response ketika verifikasi akun baru berhasil** (alur Credential Register):

```json
{
  "data": {},
  "message": "Berhasil verifikasi akun! Silahkan login.",
  "statusCode": 200,
  "status": "success"
}
```

**Contoh response ketika verifikasi lupa password berhasil** (alur Forgot Password):

```json
{
  "data": {
    "reset_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "OTP berhasil diverifikasi. Silakan lanjutkan proses reset password.",
  "statusCode": 200,
  "status": "success"
}
```

Struktur response:

| Key          | Tipe Data | Keterangan                                                                                             |
| ------------ | --------- | ------------------------------------------------------------------------------------------------------ |
| `data`       | Object    | Bernilai `{}` pada alur verifikasi akun baru. Berisi `reset_token` pada alur verifikasi lupa password. |
| `message`    | String    | Pesan yang menjelaskan hasil verifikasi.                                                               |
| `statusCode` | Integer   | HTTP status code dari hasil proses.                                                                    |
| `status`     | String    | Status hasil proses. Bernilai `success` atau `failed`.                                                 |

### Response Data (alur Forgot Password)

| Key           | Tipe Data | Keterangan                                                                                                                         |
| ------------- | --------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `reset_token` | String    | Token sementara, berlaku singkat, yang wajib dikirimkan pada endpoint **Reset Password** (`/auth/reset`) untuk mengganti password. |

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

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `email` | String | Ya | Email yang terdaftar pada sistem. Harus memiliki format email yang valid. |
| `password` | String | Ya | Password akun yang digunakan untuk proses autentikasi. Password harus memiliki minimal 5 karakter. |

### Aturan Validasi

- `email` wajib diisi.
- `email` harus memiliki format email yang valid.
- `password` wajib diisi.
- `password` harus memiliki minimal 5 karakter.
- Credential yang diberikan harus sesuai dengan data akun yang terdaftar pada sistem.
- Akun harus sudah terverifikasi agar dapat melakukan login.

### Response Sukses

```json
{
  "data": null,
  "message": "Berhasil.",
  "statusCode": 200,
  "status": "success"
}
```

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
  "statusCode": 200,
  "status": "success"
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
| `status`     | String    | Status hasil proses. Bernilai `success` atau `failed`.                 |

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

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `email` | String | Ya | Email akun yang terdaftar dan ingin melakukan reset password. |

### Aturan Validasi

- `email` wajib diisi dan harus memiliki format email yang valid.
- `email` harus terdaftar pada sistem.
- Akun terkait `email` harus sudah terverifikasi (`is_verified = true`).
- Akun terkait `email` tidak boleh menggunakan `login_type` OAuth/Google.
- Permintaan OTP untuk `email` yang sama dibatasi 1 kali setiap periode kedaluwarsa OTP untuk mencegah penyalahgunaan (spam).

### Response Sukses

```json
{
  "data": {
    "user_id": "c4e8f131-f41a-4afc-8d8a-02810cafa920"
  },
  "message": "OTP telah dikirim ke email Anda. Silakan periksa kotak masuk atau spam.",
  "statusCode": 200,
  "status": "success"
}
```

### Response Gagal

```json
{
  "data": null,
  "message": "Email tidak terdaftar!",
  "statusCode": 404,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Email belum verified! Tidak dapat reset password.",
  "statusCode": 400,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Email Anda login dengan google! Tidak dapat reset password.",
  "statusCode": 400,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terlalu banyak percobaan, coba lagi nanti.",
  "statusCode": 429,
  "status": "failed"
}
```

### Response Data

| Key       | Tipe Data | Keterangan                                                                           |
| --------- | --------- | ------------------------------------------------------------------------------------ |
| `user_id` | String    | ID unik user, wajib dikirimkan pada endpoint **Verify Credential / OTP** berikutnya. |

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

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `reset_token` | String | Ya | Token yang didapatkan dari hasil verifikasi OTP pada endpoint `/auth/verify-credential`. |
| `new_password` | String | Ya | Password baru untuk akun, minimal 5 karakter. |

### Aturan Validasi

- `reset_token` wajib diisi.
- `reset_token` harus berupa token yang valid, belum kedaluwarsa, dan belum pernah dipakai sebelumnya.
- `new_password` wajib diisi dan memiliki panjang minimal 5 karakter.

### Response Sukses

```json
{
  "data": null,
  "message": "Password berhasil direset. Silahkan login menggunakan password baru.",
  "statusCode": 200,
  "status": "success"
}
```

### Response Gagal

```json
{
  "data": null,
  "message": "Token tidak valid atau sudah kedaluwarsa.",
  "statusCode": 400,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat reset password!",
  "statusCode": 406,
  "status": "failed"
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

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `id_token` | String | Ya | ID Token yang diterima dari provider autentikasi setelah user berhasil login (contoh: Google Sign-In). |
| `provider` | String | Ya | Jenis provider yang digunakan untuk autentikasi. Saat ini hanya menerima nilai `google`. |

### Aturan Validasi

- `id_token` wajib diisi.
- `id_token` harus berupa token yang valid dan belum kedaluwarsa, serta dapat diverifikasi oleh provider terkait.
- `provider` wajib diisi.
- `provider` harus bernilai salah satu dari: `google`.

### Response Sukses

```json
{
  "data": null,
  "message": "Berhasil.",
  "statusCode": 200,
  "status": "success"
}
```

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
  "statusCode": 200,
  "status": "success"
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
  "statusCode": 200,
  "status": "success"
}
```

> Catatan: field `status` di dalam objek `data` pada endpoint ini adalah status alur autentikasi (`NEED_COMPLETE_PROFILE` / `SUCCESS`), berbeda dengan field `status` pada level response utama (`success` / `failed`).

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
| `status`     | String    | Status hasil proses. Bernilai `success` atau `failed`. |

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
  "gender": "male",
  "image_url": "https://i.pinimg.com/736x/98/d0/f6/98d0f6039d5aadb7abfc8c3b07fcc60d.jpg"
}
```

### Request Body Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `name` | String | Ya | Nama lengkap user. |
| `temp_token` | String | Ya | Token sementara yang didapatkan dari endpoint **Authentication Provider** (`/auth/provider`). Digunakan untuk memvalidasi identitas user yang telah diverifikasi oleh provider. |
| `phoneNumber` | String | Ya | Nomor telepon user. Harus memiliki panjang antara 9 sampai 15 karakter. |
| `date_of_birth` | String (ISO 8601 Date) | Ya | Tanggal lahir user, dengan format `YYYY-MM-DDTHH:mm:ssZ`. |
| `gender` | String | Ya | Jenis kelamin user. Hanya menerima nilai `male` atau `female`. |
| `image_url` | String | Tidak | Url untuk upload gambar user |

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

### Response Sukses

```json
{
  "data": null,
  "message": "Berhasil.",
  "statusCode": 200,
  "status": "success"
}
```

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
  "statusCode": 200,
  "status": "success"
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
| ------------ | --------- | ------------------------------------------------ |
| `data`       | Object    | Berisi access token dan informasi user.         |
| `message`    | String    | Pesan yang menjelaskan hasil proses registrasi. |
| `statusCode` | Integer   | HTTP status code dari hasil proses.             |
| `status`     | String    | Status hasil proses. Bernilai `success` atau `failed`. |

---

## 8. Refresh Token

Endpoint ini digunakan untuk mendapatkan kembali token baru berdasarkan `refresh_token` lama yang sudah atau akan segera kedaluwarsa (expired).

### Endpoint

```http
POST /auth/refresh-token
```

### Request Body

```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Request Body Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `refresh_token` | String | Ya | Refresh token lama yang akan digunakan untuk mendapatkan token baru. |

### Aturan Validasi

- `refresh_token` wajib diisi.

### Response Sukses

```json
{
  "data": {
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "Berhasil mendapatkan token baru.",
  "statusCode": 200,
  "status": "success"
}
```

### Response Gagal

```json
{
  "data": null,
  "message": "Refresh token tidak valid atau sudah kedaluwarsa.",
  "statusCode": 400,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat me-refresh token!",
  "statusCode": 406,
  "status": "failed"
}
```

### Response Data

| Key             | Tipe Data | Keterangan                       |
| --------------- | --------- | ----------------------------------- |
| `refresh_token` | String    | Token baru hasil dari proses refresh. |

---

## 9. Register Admin

Endpoint ini digunakan untuk membuat akun admin secara **internal**. Endpoint ini **tidak diperuntukkan untuk diakses melalui UI/frontend**, melainkan hanya dapat diakses melalui API tools seperti Postman atau semacamnya, dengan menyertakan `secret-key` pada header request.

Endpoint ini umumnya digunakan sekali di awal (initial setup) untuk membuat akun admin pertama pada sistem.

### Endpoint

```http
POST /auth/register/admin
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `secret-key` | Ya | Secret key internal yang digunakan untuk otorisasi pembuatan akun admin. |

### Request Body

```json
{
  "name": "Admin Utama",
  "email": "admin@example.com",
  "password": "SecurePass123"
}
```

### Request Body Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `name` | String | Ya | Nama lengkap admin. |
| `email` | String | Ya | Alamat email admin dengan format email yang valid. |
| `password` | String | Ya | Password admin, minimal 5 karakter. |

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
  "statusCode": 201,
  "status": "success"
}
```

- `data` bernilai `null` karena endpoint ini tidak mengembalikan data user maupun token.
- `message` berisi konfirmasi bahwa akun admin berhasil dibuat.
- `statusCode` bernilai `201`.
- `status` bernilai `success`.

### Response Gagal

```json
{
  "data": null,
  "message": "Akun admin telah terdaftar! Tidak dapat mendaftar kembali",
  "statusCode": 400,
  "status": "failed"
}
```

### Catatan

- Endpoint ini **tidak boleh** diekspos atau dipanggil dari sisi client/UI aplikasi, karena bersifat sensitif dan hanya untuk keperluan internal.
- Pastikan `secret-key` disimpan secara aman (misalnya melalui environment variable) dan tidak dibagikan ke pihak yang tidak berwenang.

---

# Store API

## 10. Create Store

Endpoint ini digunakan untuk membuat data toko/cabang (store) baru. Endpoint ini hanya dapat diakses oleh user dengan role **admin**.

### Endpoint

```http
POST /store
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token milik admin, dengan format `Bearer <token>`. |

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

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `name` | String | Ya | Nama toko/cabang. |
| `description` | String | Tidak | Deskripsi toko/cabang. Boleh bernilai `null`. |
| `alamat` | String | Ya | Alamat lengkap toko/cabang. |
| `banner_url` | String | Ya | URL gambar banner toko. Harus berupa format URL yang valid. |
| `open_hour` | Date/DateTime | Ya | Jam buka toko dalam format ISO 8601. |
| `close_hour` | Date/DateTime | Ya | Jam tutup toko dalam format ISO 8601. |
| `lat` | Float | Ya | Koordinat latitude lokasi toko. |
| `long` | Float | Ya | Koordinat longitude lokasi toko. |
| `phone_number` | String | Ya | Nomor telepon toko, minimal 9 dan maksimal 15 karakter. |

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
  "statusCode": 200,
  "status": "success"
}
```

- `data` bernilai `null` karena endpoint ini tidak mengembalikan data toko yang baru dibuat.
- `message` berisi konfirmasi bahwa toko cabang baru berhasil dibuat.
- `statusCode` bernilai `200`.
- `status` bernilai `success`.

### Response Gagal

```json
{
  "data": null,
  "message": "Anda tidak memiliki akses untuk membuat toko cabang baru!",
  "statusCode": 403,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat membuat toko cabang baru!",
  "statusCode": 406,
  "status": "failed"
}
```

---

## 11. Get All Stores

Endpoint ini digunakan untuk mendapatkan seluruh data store/cabang yang tersedia pada sistem.

### Endpoint

```http
GET /store
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token yang valid, dengan format `Bearer <token>`. |

### Query Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `name` | String | Tidak | Nama Toko |
| `sort_by` | String (name, created_at) | Tidak | Mengurutkan data toko berdasarkan name atau tanggal dibuat. default (name) |
| `page` | int | Tidak | mengambil data di halaman tertentu. default (1) |
| `limit` | int | Tidak | batasan pengambilan data. default (20) |
| `order_by` | string (asc, desc) | Tidak | diurutkan ascending atau descending. default (asc) |

### Response Sukses

```json
{
    "data": [
        {
            "id": "9122af3c-df26-48dd-b240-b6d17937a909",
            "name": "Barberstuff Cabang Tebet",
            "phone_number": "081234567890",
            "coordinate": "-6.260278,106.813889",
            "open_hour": "2026-08-31T09:00:00Z",
            "close_hour": "2026-08-31T21:00:00Z",
            "banner_url": "https://example.com/images/store-kemang-banner.jpg",
            "address": "Jl. Kemang Raya No. 45, Jakarta Selatan",
            "description": "Cabang baru di kawasan Kemang, Jakarta Selatan",
            "store_type": "lite",
            "total_service": 0,
            "total_capster": 3,
            "total_package": 0,
            "avg_rating": 5,
            "review": null,
            "status": "open",
            "created_at": "2026-09-06T06:32:11.690052Z"
        }
    ],
    "message": "Succes get data stores!",
    "statusCode": 200,
    "status": "success",
    "meta": {
        "page": 1,
        "limit": 20,
        "total_data": 1,
        "total_pages": 1
    }
}
```

### Response Gagal

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat mengambil data stores!",
  "statusCode": 406,
  "status": "failed"
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
| `status`       | String        | Status operasional store. Bernilai `open` atau `close`.          |
| `created_at`   | Date/DateTime | Waktu store dibuat, dalam format ISO 8601.                       |

---

## 12. Get Store Detail

Endpoint ini digunakan untuk mendapatkan detail satu store/cabang berdasarkan `id`, termasuk daftar service, package, rating & review, serta capster yang tersedia pada store tersebut.

### Endpoint

```http
GET /store/:id
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token yang valid, dengan format `Bearer <token>`. |

### Path Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `id` | String (UUID) | Ya | ID unik store yang dituju. |

### Response Sukses

```json
{
    "data": {
        "id": "9122af3c-df26-48dd-b240-b6d17937a909",
        "name": "Barberstuff Cabang Tebet",
        "phone_number": "081234567890",
        "coordinate": "-6.260278,106.813889",
        "open_hour": "2026-08-31T09:00:00Z",
        "close_hour": "2026-08-31T21:00:00Z",
        "banner_url": "https://example.com/images/store-kemang-banner.jpg",
        "address": "Jl. Kemang Raya No. 45, Jakarta Selatan",
        "description": "Cabang baru di kawasan Kemang, Jakarta Selatan",
        "store_type": "lite",
        "total_service": 0,
        "total_capster": 3,
        "total_package": 0,
        "avg_rating": 5,
        "review": null,
        "status": "open",
        "created_at": "2026-09-06T06:32:11.690052Z"
    },
    "message": "Succes get data store!",
    "statusCode": 200,
    "status": "success"
}
```

### Response Gagal

```json
{
  "data": null,
  "message": "Store tidak ditemukan!",
  "statusCode": 404,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat mengambil data store!",
  "statusCode": 406,
  "status": "failed"
}
```

### Struktur `data`

| Key       | Tipe Data | Keterangan                                                    |
| --------- | --------- | --------------------------------------------------------------- |
| `store`   | Object    | Informasi detail store (lihat struktur pada bagian **Get All Stores**), termasuk field tambahan `deleted_at`. |
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

---

## 13. Update Store

Endpoint ini digunakan untuk mengupdate seluruh data store/cabang berdasarkan `id`, apabila diperlukan. Header yang wajib disertakan sama seperti endpoint lain yang membutuhkan autentikasi.

### Endpoint

```http
PUT /store/:id
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token yang valid, dengan format `Bearer <token>`. |

### Path Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `id` | String (UUID) | Ya | ID unik store yang akan diupdate. |

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

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `name` | String | Ya | Nama toko/cabang. |
| `description` | String | Tidak | Deskripsi toko/cabang. Boleh bernilai `null`. |
| `address` | String | Ya | Alamat lengkap toko/cabang. |
| `banner_url` | String | Ya | URL gambar banner toko. Harus berupa format URL yang valid. |
| `open_hour` | Date/DateTime | Ya | Jam buka toko dalam format ISO 8601. |
| `close_hour` | Date/DateTime | Ya | Jam tutup toko dalam format ISO 8601. |
| `lat` | Float | Ya | Koordinat latitude lokasi toko. |
| `long` | Float | Ya | Koordinat longitude lokasi toko. |
| `phone_number` | String | Ya | Nomor telepon toko, minimal 9 dan maksimal 15 karakter. |
| `status` | String | Ya | Status toko. Hanya menerima nilai `open` atau `close`. |

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
  "statusCode": 200,
  "status": "success"
}
```

- `data` bernilai `null` karena endpoint ini tidak mengembalikan data toko yang telah diupdate.
- `message` berisi konfirmasi bahwa data toko cabang berhasil diubah.
- `statusCode` bernilai `200`.
- `status` bernilai `success`.

### Response Gagal

```json
{
  "data": null,
  "message": "Store tidak ditemukan!",
  "statusCode": 404,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat mengubah toko cabang!",
  "statusCode": 406,
  "status": "failed"
}
```

---

## 14. Delete Store

Endpoint ini digunakan untuk menghapus data store/cabang berdasarkan `id`. Penghapusan yang dilakukan bersifat **soft delete**, artinya data tidak benar-benar dihapus dari database, melainkan hanya ditandai sebagai terhapus.

### Endpoint

```http
DELETE /store/:id
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token yang valid, dengan format `Bearer <token>`. |

### Path Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `id` | String (UUID) | Ya | ID unik store yang akan dihapus. |

### Response Sukses

```json
{
  "data": null,
  "message": "Berhasil menghapus toko cabang!",
  "statusCode": 200,
  "status": "success"
}
```

- `data` bernilai `null` karena endpoint ini tidak mengembalikan data apa pun.
- `message` berisi konfirmasi bahwa toko cabang berhasil dihapus (soft delete).
- `statusCode` bernilai `200`.
- `status` bernilai `success`.

### Response Gagal

```json
{
  "data": null,
  "message": "Store tidak ditemukan!",
  "statusCode": 404,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat menghapus toko cabang!",
  "statusCode": 406,
  "status": "failed"
}
```

---

# Staff API

## 15. Create Staff Account

Endpoint ini digunakan untuk membuat akun staff (cashier/mitra) pada suatu toko cabang. Setiap toko cabang hanya memiliki dua jenis akun staff, yaitu **cashier** dan **mitra**. Endpoint ini hanya dapat diakses oleh user dengan role **admin**.

### Endpoint

```http
POST /staff
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token milik admin, dengan format `Bearer <token>`. |

### Request Body

```json
{
  "id_store": "5c2ed29d-7403-43de-9a22-90675c0d3b54",
  "name": "Ariel Cashier",
  "email": "arielmitra@gmail.com",
  "role": "cashier"
}
```

### Request Body Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `id_store` | String | Ya | ID unik store/cabang tempat akun staff ini akan ditugaskan. |
| `name` | String | Ya | Nama lengkap staff, minimal 3 karakter. |
| `email` | String | Ya | Alamat email staff dengan format email yang valid. |
| `role` | String | Ya | Role staff. Hanya menerima nilai `cashier` atau `mitra`. |

### Aturan Validasi

- Header `Authorization` wajib disertakan dengan format `Bearer <token>`, dan token harus milik user dengan role `admin`.
- `id_store` wajib diisi.
- `name` wajib diisi dan memiliki panjang minimal 3 karakter.
- `email` wajib diisi dan harus memiliki format email yang valid.
- `role` wajib diisi dan hanya menerima nilai `cashier` atau `mitra`.

### Response Sukses

```json
{
  "data": null,
  "message": "Berhasil membuat akun staaff",
  "statusCode": 200,
  "status": "success"
}
```

- `data` bernilai `null` karena endpoint ini tidak mengembalikan data akun staff yang baru dibuat.
- `message` berisi konfirmasi bahwa akun staff berhasil dibuat.
- `statusCode` bernilai `200`.
- `status` bernilai `success`.

### Response Gagal

```json
{
  "data": null,
  "message": "Anda tidak memiliki akses untuk membuat akun staff!",
  "statusCode": 403,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat membuat akun staff!",
  "statusCode": 406,
  "status": "failed"
}
```

---

## 16. Get Staff Accounts

Endpoint ini digunakan untuk mendapatkan seluruh data akun staff berdasarkan toko cabang tertentu. Endpoint ini hanya dapat diakses oleh user dengan role **admin**.

### Endpoint

```http
GET /staff
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token milik admin, dengan format `Bearer <token>`. |

### Query Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `id_store` | String | Ya | ID unik store/cabang untuk memfilter data akun staff. |
| `name` | String | Tidak | Filter berdasarkan nama staff. |
| `email` | String | Tidak | Filter berdasarkan email staff. Harus memiliki format email yang valid apabila diisi. |

### Aturan Validasi

- Header `Authorization` wajib disertakan dengan format `Bearer <token>`, dan token harus milik user dengan role `admin`.
- `id_store` wajib diisi.
- `name` bersifat opsional.
- `email` bersifat opsional, namun harus memiliki format email yang valid apabila diisi.

### Response Sukses

```json
{
  "data": [
    {
      "id": "dc58fc46-4fd4-432d-bbcb-54a2f4b9727f",
      "name": "Ariel Cashier",
      "id_store": "5c2ed29d-7403-43de-9a22-90675c0d3b54",
      "role": "cashier",
      "email": "arielmitra@gmail.com",
      "created_at": "2026-09-02T10:20:55.292672Z"
    }
  ],
  "message": "Berhasil mengambil data akun staff!",
  "statusCode": 200,
  "status": "success"
}
```

### Response Gagal

```json
{
  "data": null,
  "message": "Anda tidak memiliki akses untuk melihat data akun staff!",
  "statusCode": 403,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat mengambil data akun staff!",
  "statusCode": 406,
  "status": "failed"
}
```

### Struktur `data` (Array of Staff Account Object)

| Key          | Tipe Data     | Keterangan                                             |
| ------------ | ------------- | ---------------------------------------------------------- |
| `id`         | String (UUID) | ID unik akun staff.                                          |
| `name`       | String        | Nama staff.                                                  |
| `id_store`   | String (UUID) | ID store/cabang tempat staff bertugas.                        |
| `role`       | String        | Role staff. Bernilai `cashier` atau `mitra`.                  |
| `email`      | String        | Email staff.                                                  |
| `created_at` | Date/DateTime | Waktu akun staff dibuat, dalam format ISO 8601.                |

---

## 17. Update Staff Account

Endpoint ini digunakan untuk mengupdate data akun staff berdasarkan `id`. Seluruh role dapat mengakses endpoint ini untuk mengupdate data akun staff, **kecuali role customer**.

### Endpoint

```http
PATCH /staff/:id
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token yang valid, dengan format `Bearer <token>`. |

### Path Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `id` | String (UUID) | Ya | ID unik akun staff yang akan diupdate. |

### Request Body

```json
{
  "name": "Ariel Cashier Updated",
  "password": "NewSecurePass123"
}
```

### Request Body Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `name` | String | Ya | Nama staff, minimal 3 karakter. |
| `password` | String | Ya | Password baru untuk akun staff, minimal 5 karakter. |

### Aturan Validasi

- Header `Authorization` wajib disertakan dengan format `Bearer <token>`.
- Token tidak boleh milik user dengan role `customer`.
- `name` wajib diisi dan memiliki panjang minimal 3 karakter.
- `password` wajib diisi dan memiliki panjang minimal 5 karakter.

### Response Sukses

```json
{
  "data": null,
  "message": "Berhasil mengubah data akun staff!",
  "statusCode": 200,
  "status": "success"
}
```

- `data` bernilai `null` karena endpoint ini tidak mengembalikan data akun staff yang telah diupdate.
- `message` berisi konfirmasi bahwa data akun staff berhasil diubah.
- `statusCode` bernilai `200`.
- `status` bernilai `success`.

### Response Gagal

```json
{
  "data": null,
  "message": "Akun staff tidak ditemukan!",
  "statusCode": 404,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat mengubah data akun staff!",
  "statusCode": 406,
  "status": "failed"
}
```

---

## 18. Delete Staff Account

Endpoint ini digunakan untuk menghapus data akun staff berdasarkan `id`. Penghapusan yang dilakukan bersifat **soft delete**. Endpoint ini hanya dapat diakses oleh user dengan role **admin**, dan admin **tidak dapat menghapus akunnya sendiri**.

### Endpoint

```http
DELETE /staff/:id
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token milik admin, dengan format `Bearer <token>`. |

### Path Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `id` | String (UUID) | Ya | ID unik akun staff yang akan dihapus. |

### Aturan Validasi

- Header `Authorization` wajib disertakan dengan format `Bearer <token>`, dan token harus milik user dengan role `admin`.
- Admin tidak dapat menghapus akun staff miliknya sendiri.

### Response Sukses

```json
{
  "data": null,
  "message": "Berhasil menghapus data akun staff!",
  "statusCode": 200,
  "status": "success"
}
```

- `data` bernilai `null` karena endpoint ini tidak mengembalikan data apa pun.
- `message` berisi konfirmasi bahwa data akun staff berhasil dihapus (soft delete).
- `statusCode` bernilai `200`.
- `status` bernilai `success`.

### Response Gagal

```json
{
  "data": null,
  "message": "Anda tidak dapat menghapus akun Anda sendiri!",
  "statusCode": 400,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Akun staff tidak ditemukan!",
  "statusCode": 404,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat menghapus data akun staff!",
  "statusCode": 406,
  "status": "failed"
}
```

---

# Profile API

## 19. Get Customer Profile

Endpoint ini digunakan untuk mendapatkan data profil milik akun customer yang sedang login. Endpoint ini hanya dapat diakses oleh user dengan role **customer**.

### Endpoint

```http
GET /profile/customer
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token yang valid, dengan format `Bearer <token>`. |

### Aturan Validasi

- Header `Authorization` wajib disertakan dengan format `Bearer <token>`.
- Token harus milik user dengan role `customer`.

### Response Sukses

```json
{
  "data": {
    "id": "fb1baa4a-8593-41f8-a71a-63b06a515677",
    "name": "Budi Doremi",
    "phone_number": "081234567890",
    "date_of_birth": "2026-01-20T00:00:00Z",
    "gender": "male",
    "member_points": 100,
    "premium_type": "newbie",
    "image_url": "",
    "created_at": "2026-09-02T09:35:40.293725Z",
    "role": "customer",
    "email": "glennviktor5@gmail.com",
    "is_verified": true,
    "login_type": "Credential",
    "oauth_provider": ""
  },
  "message": "Berhasil mengambil data!",
  "statusCode": 401,
  "status": "success"
}
```

### Response Gagal

```json
{
  "data": null,
  "message": "Anda tidak memiliki akses untuk melihat profil ini!",
  "statusCode": 403,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat mengambil data profil!",
  "statusCode": 406,
  "status": "failed"
}
```

### Struktur `data`

| Key              | Tipe Data     | Keterangan                                                                     |
| ---------------- | ------------- | ---------------------------------------------------------------------------------- |
| `id`             | String (UUID) | ID unik customer.                                                                    |
| `name`           | String        | Nama customer.                                                                       |
| `phone_number`   | String        | Nomor telepon customer.                                                              |
| `date_of_birth`  | Date/DateTime | Tanggal lahir customer dalam format ISO 8601.                                       |
| `gender`         | String        | Jenis kelamin customer. Bernilai `male` atau `female`.                              |
| `member_points`  | Integer       | Jumlah poin member yang dimiliki customer.                                          |
| `premium_type`   | String        | Tipe keanggotaan premium customer. Bernilai salah satu dari: `newbie`, `bestie`, `royal`, `crazy`. |
| `image_url`      | String        | URL foto profil customer. Dapat bernilai `null`.                                    |
| `created_at`     | Date/DateTime | Waktu akun customer dibuat, dalam format ISO 8601.                                  |
| `role`           | String        | Role user, bernilai `customer`.                                                     |
| `email`          | String        | Email customer.                                                                     |
| `is_verified`    | Boolean       | Status verifikasi akun customer.                                                     |
| `login_type`     | String        | Tipe login yang digunakan customer (contoh: `Credential`, `Google`).                 |
| `oauth_provider` | String        | Nama provider OAuth yang digunakan, jika ada. Bernilai kosong apabila login menggunakan credential. |

---

## 20. Get Staff Profile

Endpoint ini digunakan untuk mendapatkan data profil milik akun staff (admin, cashier, atau mitra) yang sedang login. Endpoint ini tidak dapat diakses oleh role **customer**.

### Endpoint

```http
GET /profile/staff
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token yang valid, dengan format `Bearer <token>`. |

### Aturan Validasi

- Header `Authorization` wajib disertakan dengan format `Bearer <token>`.
- Token tidak boleh milik user dengan role `customer`.

### Response Sukses

```json
{
  "data": {
    "id": "c96d559f-182d-4f6d-82cf-92958525d25b",
    "name": "Tommy ardiansah",
    "id_store": "00000000-0000-0000-0000-000000000000",
    "role": "admin",
    "email": "tommyardiansah@gmail.com",
    "created_at": "2026-09-02T09:46:09.308996Z"
  },
  "message": "Berhasil mengambil data akun staff!",
  "statusCode": 200,
  "status": "success"
}
```

### Response Gagal

```json
{
  "data": null,
  "message": "Anda tidak memiliki akses untuk melihat profil ini!",
  "statusCode": 403,
  "status": "failed"
}
```

```json
{
  "data": null,
  "message": "Terjadi kesalahan saat mengambil data profil!",
  "statusCode": 406,
  "status": "failed"
}
```

### Struktur `data`

| Key          | Tipe Data     | Keterangan                                                                                          |
| ------------ | ------------- | -------------------------------------------------------------------------------------------------------- |
| `id`         | String (UUID) | ID unik akun staff.                                                                                          |
| `name`       | String        | Nama staff.                                                                                                  |
| `id_store`   | String (UUID) | ID store/cabang tempat staff bertugas. Bernilai UUID kosong (`00000000-0000-0000-0000-000000000000`) untuk role `admin` yang tidak terikat pada store tertentu. |
| `role`       | String        | Role staff, seperti `admin`, `cashier`, atau `mitra`.                                                       |
| `email`      | String        | Email staff.                                                                                                 |
| `created_at` | Date/DateTime | Waktu akun staff dibuat, dalam format ISO 8601.                                                              |

---

# Capster API

## 21. Create Capster

Digunakan untuk membuat capster baru berdasarkan toko cabang tertentu. Jadi capster ini terikat dengan satu toko cabang. Endpoint ini hanya bisa diakses oleh **admin**

### Endpoint

```http
POST /capster
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token milik admin, dengan format `Bearer <token>`. |

### Request Body

```json
{
    "id_store": "ccbfc173-3074-4a7d-8784-d87eb3a1d9aa",
    "name": "Ariel Capster",
    "image_url": "//example.com/images/store-kemang-banner.jpg"
}
```

### Request Body Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `id_store` | String | Ya | Id toko cabang |
| `name` | String | Ya | Nama capster yang ingin ditambahkan |
| `image_url` | String | Tidak | Gambar capster jika ingin ditambahkan |

### Aturan Validasi

- Header `Authorization` wajib disertakan dengan format `Bearer <token>`, dan token harus milik user dengan role `admin`.
- `id_store` wajib diisi.
- `name` wajib diisi dan memiliki panjang minimal 3 karakter.
- `image_url` opsional hanya jika admin mau menambahkan foto capster.

### Response Sukses

```json
{
    "data": null,
    "message": "Berhasil membuat capster baru!",
    "statusCode": 200,
    "status": "success"
}
```

### Response Gagal

```json
{
    "data": null,
    "message": "Nama capster ini sudah ada!",
    "statusCode": 400,
    "status": "failed"
}
```

```json
{
    "data": null,
    "message": "Format id toko tidak valid!",
    "statusCode": 400,
    "status": "failed"
}
```

```json
{
    "data": null,
    "message": "Toko untuk membuat capster ini tidak ditemukan!",
    "statusCode": 400,
    "status": "failed"
}
```

---

## 22. Get Capsters

Digunakan untuk mengambil data seluruh capster berdasarkan toko tertentu. Semua role dapat mengakses endpoint ini

### Endpoint

```http
GET /capster
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token yang valid, dengan format `Bearer <token>`. |

### Query Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `id_store` | String | Ya | Id toko untuk mencari data capster berdasarkan toko tertentu. |
| `name` | String | Tidak | Mencari capster berdasarkan kecocokan nama |
| `sort_by` | String (name, created_at) | Tidak | Mengurutkan data toko berdasarkan name atau tanggal dibuat. default (name) |
| `page` | int | Tidak | mengambil data di halaman tertentu. default (1) |
| `limit` | int | Tidak | batasan pengambilan data. default (20) |
| `order_by` | String (asc, desc) | Tidak | diurutkan ascending atau descending. default (asc) |

### Response Sukses

```json
{
    "data": [
        {
            "id": "91b19f40-aa77-48a7-af9f-ba596f5c960b",
            "name": "Ariel Cihuy2",
            "status": "active",
            "image_url": "https://i.pinimg.com/736x/b7/bf/d2/b7bfd20831fd88c285f6451ae54f66e6.jpg",
            "avg_rating": 5,
            "id_store": "9122af3c-df26-48dd-b240-b6d17937a909",
            "created_at": "2026-09-06T12:49:07.661718Z"
        },
        {
            "id": "8058631f-023f-4fac-98a4-ca9630bd7dfe",
            "name": "Danar Capster",
            "status": "active",
            "image_url": "https://i.pinimg.com/736x/b7/bf/d2/b7bfd20831fd88c285f6451ae54f66e6.jpg",
            "avg_rating": 5,
            "id_store": "9122af3c-df26-48dd-b240-b6d17937a909",
            "created_at": "2026-09-06T12:49:20.087862Z"
        },
        {
            "id": "c69c4d93-46f9-4d11-b468-cacdb75d9994",
            "name": "Iqbal Capster",
            "status": "active",
            "image_url": "https://i.pinimg.com/736x/b7/bf/d2/b7bfd20831fd88c285f6451ae54f66e6.jpg",
            "avg_rating": 5,
            "id_store": "9122af3c-df26-48dd-b240-b6d17937a909",
            "created_at": "2026-09-06T12:49:25.706207Z"
        }
    ],
    "message": "Succes get data capsters!",
    "statusCode": 200,
    "status": "success",
    "meta": {
        "page": 1,
        "limit": 20,
        "total_data": 3,
        "total_pages": 1
    }
}
```

### Response Gagal

```json
{
    "data": null,
    "message": "Terjadi kesalahan saat mengambil data capster!",
    "statusCode": 424,
    "status": "failed"
}
```

---

# Service

## 23. Get Data Service & Package

Mengambil data service atau package berdasarkan store tertentu. Semua role dapat mengakses endpoint ini, tapi untuk role customer hanya dapat mencari service/paket yang statusnya `active`. Seperti biasa, header wajib disertakan dengan.

### Endpoint

```http
GET /service
```

### Headers

| Key | Required | Keterangan |
| --- | --- | --- |
| `Authorization` | Ya | Access token yang valid, dengan format `Bearer <token>`. |

### Query Parameters

| Key | Tipe Data | Required | Keterangan |
| --- | --- | --- | --- |
| `id_store` | String | Ya | Untuk mencari service berdasarkan store tertentu |
| `type` | String (service, package) | Ya | Untuk mencari tip service, `service` atau `package` |
| `name` | String | Tidak | Untuk mencari nama berdasarkan kecocokan tertentu |
| `sort_by` | String | Tidak | Untuk mengorder berdasarkan field tertentu (name, price, created_at). default (name) |
| `page` | int | Tidak | mengambil data di halaman tertentu. default (1) |
| `limit` | int | Tidak | batasan pengambilan data. default (20) |
| `order_by` | String (asc, desc) | Tidak | diurutkan ascending atau descending. default (asc) |

### Response Sukses

```json
{
    "data": [],
    "message": "Succes get data stores!",
    "statusCode": 200,
    "status": "success",
    "meta": {
        "page": 1,
        "limit": 10,
        "total_data": 0,
        "total_pages": 0
    }
}
```

### Response Gagal

```json
{
  "data": null,
  "message": "Terjadi kesalahan.",
  "statusCode": 400,
  "status": "failed"
}
```

---

# API Summary

| Method | Endpoint | Fungsi |
| --- | --- | --- |
| POST | `/auth/register/credential` | Mendaftarkan user menggunakan credential/email dan mengirimkan OTP. |
| POST | `/auth/verify-credential` | Memverifikasi kode OTP, baik untuk alur verifikasi akun baru maupun alur lupa password. |
| POST | `/auth/login/credential` | Melakukan login user menggunakan email dan password untuk seluruh role yang tersedia. |
| POST | `/auth/forgot` | Memulai proses lupa password dan mengirimkan OTP ke email pengguna. |
| POST | `/auth/reset` | Mengganti password akun menggunakan `reset_token` hasil verifikasi OTP. |
| POST | `/auth/provider` | Memvalidasi `id_token` dari provider (Google) untuk menentukan apakah user perlu login atau registrasi. |
| POST | `/auth/register/oauth` | Menyelesaikan proses registrasi user baru yang login melalui provider, menggunakan `temp_token`. |
| POST | `/auth/refresh-token` | Mendapatkan token baru berdasarkan `refresh_token` lama yang sudah/akan kedaluwarsa. |
| POST | `/auth/register/admin` | Membuat akun admin secara internal (khusus API tools, wajib menyertakan header `secret-key`, tidak untuk UI). |
| POST | `/store` | Membuat data toko/cabang baru. Hanya dapat diakses oleh token milik admin. |
| GET | `/store` | Mendapatkan seluruh data store/cabang yang tersedia. |
| GET | `/store/:id` | Mendapatkan detail satu store/cabang beserta service, package, rating, dan capster-nya. |
| PUT | `/store/:id` | Mengupdate seluruh data store/cabang berdasarkan `id`. |
| DELETE | `/store/:id` | Menghapus data store/cabang berdasarkan `id` (soft delete). |
| POST | `/staff` | Membuat akun staff (cashier/mitra) untuk suatu toko cabang. Hanya dapat diakses oleh token milik admin. |
| GET | `/staff` | Mendapatkan seluruh data akun staff berdasarkan toko cabang tertentu. Hanya dapat diakses oleh token milik admin. |
| PATCH | `/staff/:id` | Mengupdate data akun staff (nama & password). Seluruh role dapat mengakses, kecuali customer. |
| DELETE | `/staff/:id` | Menghapus data akun staff (soft delete). Hanya admin, dan admin tidak dapat menghapus akunnya sendiri. |
| GET | `/profile/customer` | Mendapatkan data profil akun customer yang sedang login. |
| GET | `/profile/staff` | Mendapatkan data profil akun staff (admin/cashier/mitra) yang sedang login. |
| POST | `/capster` | Membuat capster baru yang hanya bisa dilakukan oleh admin. |
| GET | `/capster` | Mengambil data seluruh capster |
| GET | `/service` | Mengambil data service atau paket |
