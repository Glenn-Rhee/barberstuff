package repository

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type PromoRepository interface {
	FindOneWithClaimed(query interface{}, args ...interface{}) (entity.PromoClaimed, error)
	Create(v *entity.Promo) error
	Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	CountClaimed(scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Promo, error)
	FindOne(query interface{}, args ...interface{}) (entity.Promo, error)
	Updates(v interface{}, id uuid.UUID) (int64, error)
	SoftDelete(id uuid.UUID) (int64, error)
	FindAllWithClaimed(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.PromoClaimed, error)
	CreateClaimed(v *entity.PromoClaimed) error
	Transaction(fn func(tx PromoRepository) error) error
	FindOneForUpdate(query interface{}, args ...interface{}) (entity.Promo, error)
	UpdatesClaim(tx *gorm.DB, id uuid.UUID, v interface{}) (int64, error)
}

type promoRepository struct {
	db *gorm.DB
}

func NewPromoRepository(db *gorm.DB) PromoRepository {
	return &promoRepository{db: db}
}

func (r *promoRepository) FindOneWithClaimed(query interface{}, args ...interface{}) (entity.PromoClaimed, error) {
	var data entity.PromoClaimed

	result := r.db.
		Preload("Promo").
		Where(query, args...).
		First(&data)

	return data, result.Error
}

func (r *promoRepository) FindOne(query interface{}, args ...interface{}) (entity.Promo, error) {
	var data entity.Promo

	result := r.db.
		Where("deleted_at IS NULL").
		Where(query, args...).
		First(&data)

	return data, result.Error
}

func (r *promoRepository) Create(v *entity.Promo) error {
	return r.db.Model(&v).Create(v).Error
}

func (r *promoRepository) Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	result := r.db.
		Model(&entity.Promo{}).
		Scopes(scopes...).
		Count(&total)

	return total, result.Error
}
func (r *promoRepository) CountClaimed(scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	result := r.db.
		Model(&entity.PromoClaimed{}).
		Scopes(scopes...).
		Count(&total)

	return total, result.Error
}

func (r *promoRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Promo, error) {
	var promoes []entity.Promo
	result := r.db.Model(&entity.Promo{}).Scopes(scopes...).Find(&promoes)
	return promoes, result.Error
}

func (r *promoRepository) Updates(v interface{}, id uuid.UUID) (int64, error) {
	result := r.db.Model(&entity.Promo{}).
		Where("id = ?", id).
		Where("deleted_at IS NULL").
		Updates(v)
	return result.RowsAffected, result.Error
}

func (r *promoRepository) SoftDelete(id uuid.UUID) (int64, error) {
	result := r.db.
		Model(&entity.Promo{}).
		Where("id = ?", id).
		Where("deleted_at IS NULL").
		Update("deleted_at", time.Now())

	return result.RowsAffected, result.Error
}

func (r *promoRepository) FindAllWithClaimed(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.PromoClaimed, error) {
	var promoClaimeds []entity.PromoClaimed

	result := r.db.
		Model(&entity.PromoClaimed{}).
		Scopes(scopes...).
		Find(&promoClaimeds)
	return promoClaimeds, result.Error
}

func (r *promoRepository) CreateClaimed(v *entity.PromoClaimed) error {
	return r.db.Model(&v).Create(v).Error
}

func (r *promoRepository) Transaction(fn func(tx PromoRepository) error) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		return fn(&promoRepository{db: tx})
	})
}

func (r *promoRepository) FindOneForUpdate(query interface{}, args ...interface{}) (entity.Promo, error) {
	var data entity.Promo

	result := r.db.
		Clauses(clause.Locking{Strength: "UPDATE"}).
		Where("deleted_at IS NULL").
		Where(query, args...).
		First(&data)

	return data, result.Error
}

func (r *promoRepository) UpdatesClaim(tx *gorm.DB, id uuid.UUID, v interface{}) (int64, error) {
	result := tx.
		Model(&entity.PromoClaimed{}).
		Where("id = ?", id).
		Where("is_used = ?", false).
		Updates(v)

	return result.RowsAffected, result.Error
}
