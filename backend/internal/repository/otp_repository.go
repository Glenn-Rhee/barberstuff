package repository

import (
	"barberstuff_backend/internal/entity"

	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type OtpRepository interface {
	Create(tx *gorm.DB, otp *entity.OTP) (entity.OTP, error)
	FindByUserId(userId uuid.UUID) (entity.OTP, error)
	Delete(tx *gorm.DB, userId uuid.UUID) error
	Upsert(tx *gorm.DB, otp *entity.OTP) error
	IncrementAttempt(userId uuid.UUID) error
}

type otpRepository struct {
	db *gorm.DB
}

func NewOtpRepository(db *gorm.DB) OtpRepository {
	return &otpRepository{db: db}
}

func (r *otpRepository) Create(tx *gorm.DB, otp *entity.OTP) (entity.OTP, error) {
	var dataOtp entity.OTP
	result := tx.Model(&otp).Create(otp).First(&dataOtp)
	return dataOtp, result.Error
}

func (r *otpRepository) Upsert(tx *gorm.DB, otp *entity.OTP) error {
	return tx.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "id_user"}},
		DoUpdates: clause.AssignmentColumns([]string{"otp", "expired_at", "created_at"}),
	}).Create(otp).Error
}

func (r *otpRepository) IncrementAttempt(userId uuid.UUID) error {
	return r.db.Model(&entity.OTP{}).
		Where("id_user = ?", userId).
		UpdateColumn("attempt_count", gorm.Expr("attempt_count + 1")).
		Error
}

func (r *otpRepository) FindByUserId(userId uuid.UUID) (entity.OTP, error) {
	var dataOtp entity.OTP
	result := r.db.Where(&entity.OTP{IDUser: userId}).First(&dataOtp)

	return dataOtp, result.Error
}

func (r *otpRepository) Delete(tx *gorm.DB, userId uuid.UUID) error {
	result := tx.Where("id_user = ?", userId).Delete(&entity.OTP{})

	return result.Error
}
