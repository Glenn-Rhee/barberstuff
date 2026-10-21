package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type DeviceTokenRepository interface {
	Upsert(d *entity.DeviceToken) error
	FindOne(where interface{}, args ...interface{}) (entity.DeviceToken, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.DeviceToken, error)
	Deactive(v interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
}

type deviceTokenRepoitory struct {
	db *gorm.DB
}

func NewDeviceTokenRepository(db *gorm.DB) DeviceTokenRepository {
	return &deviceTokenRepoitory{db: db}
}

func (r *deviceTokenRepoitory) Upsert(d *entity.DeviceToken) error {
	return r.db.Clauses(clause.OnConflict{
		Columns: []clause.Column{{Name: "fcm_token"}},
		DoUpdates: clause.Assignments(map[string]interface{}{
			"id_user":      d.IdUser,
			"platform":     d.Platform,
			"app_version":  d.AppVersion,
			"is_active":    true,
			"last_seen_at": d.LastSeenAt,
		}),
	}).Create(d).Error
}

func (r *deviceTokenRepoitory) FindOne(where interface{}, args ...interface{}) (entity.DeviceToken, error) {
	var d entity.DeviceToken
	err := r.db.
		Where(where, args...).
		First(&d).Error

	return d, err
}

func (r *deviceTokenRepoitory) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.DeviceToken, error) {
	var devices []entity.DeviceToken

	err := r.db.Scopes(scopes...).Find(&devices).Error
	return devices, err
}

func (r *deviceTokenRepoitory) Deactive(v interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	result := r.db.Model(&entity.DeviceToken{}).
		Where("is_active = ?", true).
		Scopes(scopes...).
		Updates(v)

	return result.RowsAffected, result.Error
}
