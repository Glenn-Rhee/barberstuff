# Dibaca otomatis oleh plugin Gradle Flutter untuk build release.

# google_sign_in 7 memakai Credential Manager. R8 membuang kelas-kelas ini
# karena cuma dipanggil lewat refleksi, akibatnya login Google gagal tepat
# setelah akun dipilih.
-if class androidx.credentials.CredentialManager
-keep class androidx.credentials.playservices.** { *; }
-keep class com.google.android.libraries.identity.googleid.** { *; }
-keep class com.google.android.gms.auth.api.identity.** { *; }
