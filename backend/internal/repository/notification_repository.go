package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type NotificationRepository interface {
	Create(tx *gorm.DB, n *entity.Notification, opts ...clause.Expression) error
	CreateBatch(tx *gorm.DB, items []entity.Notification, batchSize int, opts ...clause.Expression) (int64, error)
	FindOne(tx *gorm.DB, where interface{}, args ...interface{}) (entity.Notification, error)
	FindAll(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Notification, error)
	Count(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	Updates(tx *gorm.DB, v interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
}

type notificationRepository struct {
	db *gorm.DB
}

func NewNotificationRepository(d *gorm.DB) NotificationRepository {
	return &notificationRepository{db: d}
}

func (r *notificationRepository) Create(tx *gorm.DB, n *entity.Notification, opts ...clause.Expression) error {
	return conn(r.db, tx).Clauses(opts...).Create(n).Error
}

func (r *notificationRepository) CreateBatch(tx *gorm.DB, items []entity.Notification, batchSize int, opts ...clause.Expression) (int64, error) {
	res := conn(r.db, tx).Clauses(opts...).CreateInBatches(items, batchSize)
	return res.RowsAffected, res.Error
}

func (r *notificationRepository) FindOne(tx *gorm.DB, where interface{}, args ...interface{}) (entity.Notification, error) {
	var n entity.Notification
	res := conn(r.db, tx).Where(where, args...).First(&n)

	return n, res.Error
}

func (r *notificationRepository) FindAll(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Notification, error) {
	var list []entity.Notification

	res := conn(r.db, tx).Scopes(scopes...).Find(&list)
	return list, res.Error
}

func (r *notificationRepository) Count(tx *gorm.DB, scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var count int64

	res := conn(r.db, tx).Model(&entity.Notification{}).Scopes(scopes...).Count(&count)
	return count, res.Error
}

func (r *notificationRepository) Updates(tx *gorm.DB, v interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	res := conn(r.db, tx).Model(&entity.Notification{}).Scopes(scopes...).Updates(v)
	return res.RowsAffected, res.Error
}
