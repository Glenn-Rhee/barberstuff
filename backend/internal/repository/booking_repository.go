package repository

import (
	"barberstuff_backend/internal/entity"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type BookingRepository interface {
	FindOne(query interface{}, args ...interface{}) (entity.Booking, error)
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Booking, error)
	Create(tx *gorm.DB, b *entity.Booking) error
	Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
	UpdateStatusMany(ids []uuid.UUID, status entity.BookingStatusEnum) error
	FindFavoriteServiceByUserIDs(userIDs []uuid.UUID) ([]entity.FavoriteServiceResult, error)
	Updates(tx *gorm.DB, value interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error)
}

type bookingRepository struct {
	db *gorm.DB
}

func NewBookingRepository(db *gorm.DB) BookingRepository {
	return &bookingRepository{db: db}
}

func (r *bookingRepository) FindOne(query interface{}, args ...interface{}) (entity.Booking, error) {
	var data entity.Booking
	result := r.db.
		Preload("BookingItems", func(db *gorm.DB) *gorm.DB {
			return db.Preload("Service")
		}).
		Where(query, args...).First(&data)
	return data, result.Error
}

func (r *bookingRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Booking, error) {
	var dataBooking []entity.Booking
	result := r.db.
		Preload("Store").
		Preload("Employee", func(d *gorm.DB) *gorm.DB {
			return d.
				Joins("JOIN position ON position.id = employee.id_position").
				Where("employee.deleted_at IS NULL").
				Where("position.deleted_at IS NULL").
				Where("position.name ILIKE ?", "%capster%")
		}).
		Preload("Staff").
		Preload("Customer", func(db *gorm.DB) *gorm.DB {
			return db.Preload("PremiumType")
		}).
		Preload("Ratings", func(db *gorm.DB) *gorm.DB {
			return db.Preload("Store").
				Preload("Employee").
				Preload("Staff", func(d *gorm.DB) *gorm.DB {
					return d.
						Joins("JOIN position ON position.id = employee.id_position").
						Where("employee.deleted_at IS NULL").
						Where("position.deleted_at IS NULL").
						Where("position.name ILIKE ?", "%capster%")
				})
		}).
		Preload("BookingItems", func(db *gorm.DB) *gorm.DB {
			return db.Preload("Service")
		}).
		Scopes(scopes...).
		Find(&dataBooking)

	return dataBooking, result.Error
}

func (r *bookingRepository) Create(tx *gorm.DB, b *entity.Booking) error {
	return tx.Create(&b).Error
}

func (r *bookingRepository) Count(scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	var total int64
	result := r.db.Model(&entity.Booking{}).Count(&total).Scopes(scopes...)
	return total, result.Error
}

func (r *bookingRepository) UpdateStatusMany(ids []uuid.UUID, status entity.BookingStatusEnum) error {
	return r.db.Model(&entity.Booking{}).
		Where("id IN ?", ids).
		Update("status_booking", status).Error
}

func (r *bookingRepository) FindFavoriteServiceByUserIDs(userIDs []uuid.UUID) ([]entity.FavoriteServiceResult, error) {
	var results []entity.FavoriteServiceResult

	err := r.db.Raw(`
		SELECT id_user, id_service, service_name, total_order
        FROM (
            SELECT
                b.id_user,
                s.id AS id_service,
                s.name AS service_name,
                COUNT(*) AS total_order,
                ROW_NUMBER() OVER (
                    PARTITION BY b.id_user
                    ORDER BY COUNT(*) DESC, MAX(b.created_at) DESC
                ) AS rn
            FROM booking b
            JOIN booking_item bi ON bi.id_booking = b.id
            JOIN service s ON s.id = bi.id_service
            WHERE b.id_user IN ?
              AND b.status_booking = ?
            GROUP BY b.id_user, s.id, s.name
        ) ranked
        WHERE rn = 1
	`, userIDs, entity.BookingStatusCompleted).Scan(&results).Error

	return results, err
}

func (r *bookingRepository) Updates(tx *gorm.DB, value interface{}, scopes ...func(*gorm.DB) *gorm.DB) (int64, error) {
	result := tx.
		Model(&entity.Booking{}).
		Scopes(scopes...).
		Updates(value)
	return result.RowsAffected, result.Error
}
