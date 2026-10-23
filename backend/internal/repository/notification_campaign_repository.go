package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type NotificationCampaignRepository interface {
	Create(tx *gorm.DB, c *entity.NotificationCampaign, opts ...clause.Expression) error
	FindOne(tx *gorm.DB, where interface{}, args ...interface{}) (entity.NotificationCampaign, error)
	FindAll(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) ([]entity.NotificationCampaign, error)
	Count(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	Updates(tx *gorm.DB, v interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
}

type notificationCampaignRepository struct {
	db *gorm.DB
}

func NewNotificationCampaignRepository(d *gorm.DB) NotificationCampaignRepository {
	return &notificationCampaignRepository{db: d}
}

func (r *notificationCampaignRepository) Create(tx *gorm.DB, c *entity.NotificationCampaign, opts ...clause.Expression) error {
	return conn(r.db, tx).Clauses(opts...).Create(c).Error
}

func (r *notificationCampaignRepository) FindOne(tx *gorm.DB, where interface{}, args ...interface{}) (entity.NotificationCampaign, error) {
	var nc entity.NotificationCampaign
	res := conn(r.db, tx).Where(where, args...).First(&nc).Error

	return nc, res
}

func (r *notificationCampaignRepository) FindAll(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) ([]entity.NotificationCampaign, error) {
	var ncs []entity.NotificationCampaign
	res := conn(r.db, tx).Scopes(scopes...).Find(&ncs)
	return ncs, res.Error
}

func (r *notificationCampaignRepository) Count(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	res := conn(r.db, tx).Model(&entity.NotificationCampaign{}).Scopes(scopes...).Count(&total)
	return total, res.Error
}

func (r *notificationCampaignRepository) Updates(tx *gorm.DB, v interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	res := conn(r.db, tx).Model(&entity.NotificationCampaign{}).Scopes(scopes...).Updates(v)
	return res.RowsAffected, res.Error
}
