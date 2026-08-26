package helper

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"io"
	"log"
	"os"

	"github.com/joho/godotenv"
)

var ErrInvalidCiphertext = errors.New("ciphertext tidak valid")

// getEncryptionKey ambil key dari env, harus 32 byte (AES-256)
func getEncryptionKey() ([]byte, error) {
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
			return nil, err
		}
	}
	key := os.Getenv("OTP_ENCRYPTION_KEY")
	log.Println(len(key))
	log.Println(key)
	if len(key) != 32 {
		return nil, errors.New("OTP_ENCRYPTION_KEY harus 32 karakter (AES-256)")
	}
	return []byte(key), nil
}

// Encrypt mengubah plaintext menjadi ciphertext (base64 string)
func Encrypt(plaintext string) (string, error) {
	key, err := getEncryptionKey()
	if err != nil {
		return "", err
	}

	block, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	nonce := make([]byte, gcm.NonceSize())
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return "", err
	}

	// Nonce digabung di depan ciphertext, biar gampang di-decrypt nanti
	ciphertext := gcm.Seal(nonce, nonce, []byte(plaintext), nil)

	return base64.StdEncoding.EncodeToString(ciphertext), nil
}

// Decrypt mengubah ciphertext (base64 string) kembali ke plaintext asli
func Decrypt(encrypted string) (string, error) {
	key, err := getEncryptionKey()
	if err != nil {
		return "", err
	}

	data, err := base64.StdEncoding.DecodeString(encrypted)
	if err != nil {
		return "", ErrInvalidCiphertext
	}

	block, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	nonceSize := gcm.NonceSize()
	if len(data) < nonceSize {
		return "", ErrInvalidCiphertext
	}

	nonce, ciphertext := data[:nonceSize], data[nonceSize:]

	plaintext, err := gcm.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		return "", ErrInvalidCiphertext
	}

	return string(plaintext), nil
}
