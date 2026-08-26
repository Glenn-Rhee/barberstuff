package lib

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"errors"
	"log"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/joho/godotenv"
)

var (
	ErrTokenExpired = errors.New("token sudah kadaluarsa")
	ErrTokenInvalid = errors.New("token tidak valid")
)

type CustomClaims struct {
	dto.UserAuth
	jwt.RegisteredClaims
}

// ============================
// 1. GENERATE TOKEN
// ============================
func GenerateToken(userID, email string, role entity.RoleEnum, duration time.Duration) (string, error) {
	now := time.Now()
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}

	log.Println([]byte(os.Getenv("JWT_KEY")))

	claims := CustomClaims{
		UserAuth: dto.UserAuth{
			UserId: userID,
			Email:  email,
			Role:   role,
		},
		RegisteredClaims: jwt.RegisteredClaims{
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(duration)),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    "myapp",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signedToken, err := token.SignedString([]byte(os.Getenv("JWT_KEY")))
	if err != nil {
		return "", err
	}

	return signedToken, nil
}

// ============================
// 2. PARSE TOKEN
// ============================
func ParseToken(tokenString string) (*CustomClaims, error) {
	claims := &CustomClaims{}
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrTokenInvalid
		}
		return os.Getenv("JWT_KEY"), nil
	})

	if err != nil {
		if errors.Is(err, jwt.ErrTokenExpired) {
			return nil, ErrTokenExpired
		}
		return nil, ErrTokenInvalid
	}

	if !token.Valid {
		return nil, ErrTokenInvalid
	}

	return claims, nil
}

// ============================
// 3. VALIDASI TOKEN (cek valid & belum expired)
// ============================
func ValidateToken(tokenString string) error {
	_, err := ParseToken(tokenString)
	return err
}

// ============================
// 4. CEK APAKAH TOKEN SUDAH EXPIRED SAJA (tanpa peduli valid/tidak signature)
// ============================
func IsTokenExpired(tokenString string) bool {
	claims := &CustomClaims{}
	_, _, err := jwt.NewParser().ParseUnverified(tokenString, claims)
	if err != nil {
		return true
	}
	if claims.ExpiresAt == nil {
		return true
	}
	return time.Now().After(claims.ExpiresAt.Time)
}

// ============================
// 5. REFRESH TOKEN
// ============================
func RefreshToken(oldTokenString string, newDuration time.Duration) (string, error) {
	claims, err := ParseToken(oldTokenString)
	if err != nil && !errors.Is(err, ErrTokenExpired) {
		return "", err
	}

	return GenerateToken(claims.UserAuth.UserId, claims.UserAuth.Email, claims.UserAuth.Role, newDuration)
}

// ============================
// 6. EXTRACT TOKEN DARI HEADER
// ============================
func ExtractTokenFromHeader(authHeader string) (string, error) {
	const prefix = "Bearer "
	if len(authHeader) <= len(prefix) || authHeader[:len(prefix)] != prefix {
		return "", errors.New("format header authorization tidak valid")
	}
	return authHeader[len(prefix):], nil
}
