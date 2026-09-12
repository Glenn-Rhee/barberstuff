package lib

import (
	"barberstuff_backend/internal/dto"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/MicahParks/keyfunc/v3"
	"github.com/golang-jwt/jwt/v5"
	"github.com/joho/godotenv"
)

type ClaimsGoogle struct {
	jwt.MapClaims
}

func VerifyIdTokenGoogle(rawToken string) (dto.GoogleClaims, error) {
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}
	k, err := keyfunc.NewDefaultCtx(context.Background(), []string{os.Getenv("GOOGLE_JWKS_URL")})
	if err != nil {
		return dto.GoogleClaims{}, fmt.Errorf("Gagal ambil JWKS: %v", err.Error())
	}
	token, err := jwt.Parse(rawToken, k.Keyfunc)
	if err != nil {
		return dto.GoogleClaims{}, fmt.Errorf("Token invalid: %v", err.Error())
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return dto.GoogleClaims{}, fmt.Errorf("Claims tidak valid")
	}

	if claims["aud"] != os.Getenv("GOOGLE_CLIENT_ID") {
		return dto.GoogleClaims{}, fmt.Errorf("Audince tidak cocok")
	}

	iss, _ := claims["iss"].(string)
	if iss != "https://accounts.google.com" && iss != "accounts.google.com" {
		return dto.GoogleClaims{}, fmt.Errorf("Issuer tidak valid")
	}

	claimsJson, err := json.Marshal(claims)
	if err != nil {
		return dto.GoogleClaims{}, fmt.Errorf("Gagal marshal claims: %v", err)
	}

	var googleClaims dto.GoogleClaims
	if err := json.Unmarshal(claimsJson, &googleClaims); err != nil {
		return dto.GoogleClaims{}, fmt.Errorf("Gagal unmarshal claims: %v", err)
	}

	return googleClaims, nil
}
