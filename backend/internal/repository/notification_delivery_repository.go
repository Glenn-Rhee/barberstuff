package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type NotificationDeliveryRepository interface {
	CreateBatch(tx *gorm.DB, items []entity.NotificationDelivery, batchSize int, opts ...clause.Expression) error
	FindOne(tx *gorm.DB, where interface{}, args ...interface{}) (entity.NotificationDelivery, error)
	FindAll(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) ([]entity.NotificationDelivery, error)
	Count(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	Updates(tx *gorm.DB, v interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	Delete(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	Scan(tx *gorm.DB, dest interface{}, scopes ...func(*gorm.DB) *gorm.DB) error
}

type notificationDeliveryRepository struct {
	db *gorm.DB
}

func NewNotificationDelivery(d *gorm.DB) NotificationDeliveryRepository {
	return &notificationDeliveryRepository{db: d}
}

func (r *notificationDeliveryRepository) CreateBatch(tx *gorm.DB, items []entity.NotificationDelivery, batchSize int, opts ...clause.Expression) error {
	return conn(r.db, tx).Clauses(opts...).CreateInBatches(items, batchSize).Error
}

func (r *notificationDeliveryRepository) FindOne(tx *gorm.DB, where interface{}, args ...interface{}) (entity.NotificationDelivery, error) {
	var nd entity.NotificationDelivery
	res := conn(r.db, tx).Where(where, args...).First(&nd)
	return nd, res.Error
}

func (r *notificationDeliveryRepository) FindAll(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) ([]entity.NotificationDelivery, error) {
	var list []entity.NotificationDelivery
	res := conn(r.db, tx).Scopes(scopes...).Find(&list)
	return list, res.Error
}

func (r *notificationDeliveryRepository) Count(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	res := conn(r.db, tx).Model(&entity.NotificationDelivery{}).Scopes(scopes...).Count(&total)

	return total, res.Error
}

func (r *notificationDeliveryRepository) Updates(tx *gorm.DB, v interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	res := conn(r.db, tx).Model(&entity.NotificationDelivery{}).Scopes(scopes...).Updates(v)
	return res.RowsAffected, res.Error
}

func (r *notificationDeliveryRepository) Delete(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	res := conn(r.db, tx).Scopes(scopes...).Delete(&entity.NotificationDelivery{})
	return res.RowsAffected, res.Error
}

func (r *notificationDeliveryRepository) Scan(tx *gorm.DB, dest interface{}, scopes ...func(*gorm.DB) *gorm.DB) error {
	return conn(r.db, tx).Model(&entity.NotificationDelivery{}).Scopes(scopes...).Scan(dest).Error
}
