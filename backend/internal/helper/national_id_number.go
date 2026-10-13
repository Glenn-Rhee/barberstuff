package helper

import (
	"errors"
	"log"
	"time"
)

// Kode provinsi yang dikenal (termasuk pemekaran Papua).
var provinsi = map[string]string{
	"11": "Aceh", "12": "Sumatera Utara", "13": "Sumatera Barat", "14": "Riau",
	"15": "Jambi", "16": "Sumatera Selatan", "17": "Bengkulu", "18": "Lampung",
	"19": "Kepulauan Bangka Belitung", "21": "Kepulauan Riau",
	"31": "DKI Jakarta", "32": "Jawa Barat", "33": "Jawa Tengah",
	"34": "DI Yogyakarta", "35": "Jawa Timur", "36": "Banten",
	"51": "Bali", "52": "Nusa Tenggara Barat", "53": "Nusa Tenggara Timur",
	"61": "Kalimantan Barat", "62": "Kalimantan Tengah", "63": "Kalimantan Selatan",
	"64": "Kalimantan Timur", "65": "Kalimantan Utara",
	"71": "Sulawesi Utara", "72": "Sulawesi Tengah", "73": "Sulawesi Selatan",
	"74": "Sulawesi Tenggara", "75": "Gorontalo", "76": "Sulawesi Barat",
	"81": "Maluku", "82": "Maluku Utara",
	"91": "Papua", "92": "Papua Barat", "93": "Papua Selatan",
	"94": "Papua Tengah", "95": "Papua Pegunungan", "96": "Papua Barat Daya",
}

// Info berisi data hasil parsing NIK yang valid.
type Info struct {
	KodeProvinsi  string
	Provinsi      string
	KodeKabKota   string
	KodeKecamatan string
	TanggalLahir  time.Time
	JenisKelamin  string // "Laki-laki" / "Perempuan"
	NomorUrut     string
}

var (
	ErrPanjang      = errors.New("NIK harus terdiri dari 16 digit")
	ErrBukanAngka   = errors.New("NIK hanya boleh berisi angka")
	ErrProvinsi     = errors.New("kode provinsi tidak valid")
	ErrWilayah      = errors.New("kode kabupaten/kota atau kecamatan tidak valid")
	ErrTanggalLahir = errors.New("tanggal lahir pada NIK tidak valid")
	ErrNomorUrut    = errors.New("nomor urut tidak valid")
)

// Validate memeriksa format NIK dan mengembalikan informasi yang terkandung di dalamnya.
func ValidateIdentityNumber(identityNumber string) (*Info, error) {
	log.Printf("identityNumber=%q len=%d", identityNumber, len(identityNumber))
	// 1. Panjang harus 16
	if len(identityNumber) != 16 {
		return nil, ErrPanjang
	}

	// 2. Semua karakter harus angka
	for i := 0; i < len(identityNumber); i++ {
		if identityNumber[i] < '0' || identityNumber[i] > '9' {
			return nil, ErrBukanAngka
		}
	}

	// 3. Kode provinsi
	kodeProv := identityNumber[0:2]
	namaProv, ok := provinsi[kodeProv]
	if !ok {
		return nil, ErrProvinsi
	}

	// 4. Kode kab/kota & kecamatan tidak boleh "00"
	kodeKab, kodeKec := identityNumber[2:4], identityNumber[4:6]
	if kodeKab == "00" || kodeKec == "00" {
		return nil, ErrWilayah
	}

	// 5. Tanggal lahir
	day := int(identityNumber[6]-'0')*10 + int(identityNumber[7]-'0')
	month := int(identityNumber[8]-'0')*10 + int(identityNumber[9]-'0')
	yy := int(identityNumber[10]-'0')*10 + int(identityNumber[11]-'0')

	gender := "Laki-laki"
	if day > 40 {
		gender = "Perempuan"
		day -= 40
	}

	now := time.Now()
	// Tentukan abad: jika yy <= tahun sekarang (2 digit) -> 2000-an, selain itu 1900-an
	year := 1900 + yy
	if yy <= now.Year()%100 {
		year = 2000 + yy
	}

	tgl := time.Date(year, time.Month(month), day, 0, 0, 0, 0, time.UTC)
	// Cek hasil normalisasi time.Date (mis. 31 Februari akan bergeser ke Maret)
	if tgl.Day() != day || int(tgl.Month()) != month || tgl.Year() != year {
		return nil, ErrTanggalLahir
	}
	if tgl.After(now) {
		return nil, ErrTanggalLahir
	}

	// 6. Nomor urut tidak boleh 0000
	urut := identityNumber[12:16]
	if urut == "0000" {
		return nil, ErrNomorUrut
	}

	return &Info{
		KodeProvinsi:  kodeProv,
		Provinsi:      namaProv,
		KodeKabKota:   kodeKab,
		KodeKecamatan: kodeKec,
		TanggalLahir:  tgl,
		JenisKelamin:  gender,
		NomorUrut:     urut,
	}, nil
}

// IsValid versi ringkas yang hanya mengembalikan bool.
func IsIdentityValid(identityNumber string) bool {
	_, err := ValidateIdentityNumber(identityNumber)
	return err == nil
}
