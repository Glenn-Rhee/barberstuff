# Mobile BarberStuff

Aplikasi customer BarberStuff (Flutter, state management `provider`).

## Peta folder `lib/`

```
lib/
├── main.dart                 Titik masuk: muat sesi, cache, bahasa, notifikasi, lalu runApp
├── app/
│   ├── app.dart              MaterialApp (tema, bahasa, builder global)
│   ├── app_providers.dart    Daftar semua dependency (service inti + tiap fitur)
│   └── app_route.dart        Semua nama rute dan halaman yang dibukanya
│
├── core/                     Hal teknis yang tidak tahu soal fitur apa pun
│   ├── config/               Base URL, endpoint, env (env.dart tidak di-commit)
│   ├── constants/            Path aset, durasi animasi
│   ├── deeplink/             Tautan cabang yang dibagikan (/s/<id>)
│   ├── localization/         LocaleController (bahasa yang dipilih user)
│   ├── network/              DioClient, ApiResponse, ApiException + pesannya
│   ├── storage/              AppCache (cache offline), AppSession (token login)
│   ├── services/             Layanan perangkat: lokasi, notifikasi, kamera/galeri,
│   │                         upload gambar, Google Sign-In
│   ├── theme/                Warna, gaya teks, tema, warna tier member
│   ├── usecase/              Kontrak UseCase
│   └── utils/                Fungsi kecil murni: format tanggal/harga/nama/HP,
│                             validator, pembaca JSON, buka link eksternal
│
├── features/                 Satu folder per fitur (lihat pola di bawah)
│   ├── auth/  booking/  history/  home/  main_shell/  notification/
│   ├── onboarding/  profile/  promo/  splash/  store/
│   └── debug/                Panel debug (hanya untuk mode debug)
│
├── shared/                   Komponen UI yang dipakai lebih dari satu fitur
│   ├── dialogs/              showConfirmDialog, PermissionPrompt, coming soon
│   ├── mixins/               AvatarFormMixin
│   ├── transitions/          CircularRevealRoute
│   └── widgets/
│       ├── avatar/           Pemilih foto profil
│       ├── branding/         Logo animasi, pola latar
│       ├── buttons/          BoxButton, CircleIconButton, AppTextLink
│       ├── feedback/         Toast, loading, skeleton, error + retry, banner offline
│       ├── form/             Text field, dropdown, search bar, filter chip, dll
│       ├── media/            StoreImage
│       └── navigation/       AppBackBar, DashboardBottomNav
│
└── l10n/                     File .arb + hasil generate (jangan diedit manual)
```

## Pola satu fitur

Fitur yang bicara dengan server memakai tiga lapis:

```
features/<fitur>/
├── <fitur>_injection.dart    Rakitan provider: datasource → repository → use case
├── data/                     Bicara dengan API / cache
│   ├── datasources/          Panggilan HTTP atau baca cache mentah
│   ├── models/               Parsing JSON → entity
│   └── repositories/         Implementasi kontrak repository
├── domain/                   Aturan bisnis, tanpa Flutter
│   ├── entities/             Objek data yang dipakai layar
│   ├── repositories/         Kontrak (abstract) repository
│   └── usecases/             Satu aksi bisnis per file
└── presentation/             Semua yang tampil di layar
    ├── pages/                Satu file per halaman (route)
    ├── provider/             ChangeNotifier untuk state halaman
    ├── models/               Data/teks khusus tampilan (bukan dari server)
    ├── utils/                Helper khusus fitur ini
    └── widgets/              Potongan UI, satu komponen utama per file
```

Arah ketergantungan: `presentation → domain ← data`. Halaman memanggil
use case lewat provider, tidak pernah memanggil datasource langsung.

Fitur yang cuma tampilan (home, onboarding, splash, main_shell) hanya punya
folder `presentation/`.

## Aturan kecil supaya tetap rapi

- Satu file = satu widget publik utama. Widget privat (`_Nama`) boleh ikut
  di file yang sama kalau cuma dipakai di situ.
- Komponen yang dipakai dua fitur atau lebih pindah ke `shared/`.
- Fungsi murni (format, parsing) masuk `core/utils/`, bukan di file halaman.
- Halaman dengan AppBar standar pakai `AppBackBar`; dialog ya/tidak pakai
  `showConfirmDialog`.
- Import selalu `package:mobile_barberstuff/...` dan urut abjad
  (`dart fix --apply` membereskan urutannya).

## Perintah

```bash
flutter pub get
flutter gen-l10n        # setelah mengubah file .arb
flutter analyze
flutter test
```
