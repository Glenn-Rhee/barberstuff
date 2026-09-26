package lib

import (
	"barberstuff_backend/internal/helper"
	"context"
	"errors"
	"log"
	"os"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/joho/godotenv"
)

var S3Client *s3.Client
var s3PressignClient *s3.PresignClient

func StorageInit() {
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}
	endPoint := "https://" + os.Getenv("WASABI_ENDPOINT")
	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(os.Getenv("WASABI_REGION")),
		config.WithCredentialsProvider(credentials.NewStaticCredentialsProvider(
			os.Getenv("WASABI_ACCESS_KEY"),
			os.Getenv("WASABI_SECRET_KEY"),
			"",
		)),
	)

	if err != nil {
		panic("Failed load config wasabi: " + err.Error())
	}

	S3Client = s3.NewFromConfig(cfg, func(o *s3.Options) {
		o.BaseEndpoint = aws.String(endPoint)
		o.UsePathStyle = true
	})

	s3PressignClient = s3.NewPresignClient(S3Client)
}

func GenereatePresignedUploadURL(objectKey string, contentType string) (string, error) {
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}

	bucket := os.Getenv("WASABI_BUCKET")

	req, err := s3PressignClient.PresignPutObject(context.TODO(), &s3.PutObjectInput{
		Bucket:      aws.String(bucket),
		Key:         aws.String(objectKey),
		ContentType: aws.String(contentType),
	}, s3.WithPresignExpires(5*time.Minute))

	if err != nil {
		return "", err
	}

	return req.URL, nil
}

const (
	MinFileSize = 1024            // 1KB
	MaxFileSize = 5 * 1024 * 1024 // 5MB
)

type WasabiError error

var (
	WasabiErrMaxSize WasabiError = errors.New("Ukuran gambar terlalu besar")
)

func MoveObjectToPermanent(ctx context.Context, tempKey string) (string, error) {
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}
	bucket := os.Getenv("WASABI_BUCKET")

	if strings.Split(tempKey, "/")[0] != "temp" {
		return "", errors.New("Image url harus berupa object key.")
	}

	// Cek ukuran file yang SEBENARNYA ter-upload
	head, err := S3Client.HeadObject(ctx, &s3.HeadObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(tempKey),
	})
	if err != nil {
		helper.Logger("failed move object", "move to object permanent", err)
		return "", errors.New("Gagal membuat data, periksa image url.")
	}

	size := *head.ContentLength
	if size < MinFileSize || size > MaxFileSize {
		// Tolak: hapus file yang melanggar batas dari folder temp/
		S3Client.DeleteObject(ctx, &s3.DeleteObjectInput{
			Bucket: aws.String(bucket),
			Key:    aws.String(tempKey),
		})
		helper.Logger("failed move object", "move to object permanent", err)
		return "", errors.New("Gagal membuat data, periksa image url.")
	}

	permanentKey := strings.Replace(tempKey, "temp/", "uploads/", 1)
	copySource := bucket + "/" + tempKey

	_, err = S3Client.CopyObject(ctx, &s3.CopyObjectInput{
		Bucket:     aws.String(bucket),
		CopySource: aws.String(copySource),
		Key:        aws.String(permanentKey),
	})
	if err != nil {
		helper.Logger("failed move object", "move to object permanent", err)
		return "", errors.New("Gagal membuat data, periksa image url.")
	}

	err = DeleteObject(ctx, tempKey)
	if err != nil {
		helper.Logger("failed move object", "move to object permanent", err)
		return "", errors.New("Gagal membuat data, periksa image url.")
	}

	return permanentKey, nil
}

func DeleteObject(ctx context.Context, key string) error {
	if key == "" {
		return nil // tidak ada yang perlu dihapus
	}
	bucket := os.Getenv("WASABI_BUCKET")

	_, err := S3Client.DeleteObject(ctx, &s3.DeleteObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
	})
	return err
}
