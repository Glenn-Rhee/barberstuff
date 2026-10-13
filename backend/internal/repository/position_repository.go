package repository

import (
	"barberstuff_backend/internal/entity"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type PositionRepository interface {
	Create(p *entity.Position) error
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Position, error)
	Updates(v interface{}, id uuid.UUID) (int64, error)
	SoftDelete(id uuid.UUID) (int64, error)
	FindOne(where interface{}, args ...interface{}) (entity.Position, error)
}

type positionRepository struct {
	db *gorm.DB
}

func NewPositionRepository(db *gorm.DB) PositionRepository {
	return &positionRepository{db: db}
}

func (r *positionRepository) Create(p *entity.Position) error {
	result := r.db.Model(&p).Create(p)
	return result.Error
}

func (r *positionRepository) FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Position, error) {
	var positions []entity.Position

	result := r.db.
		Model(&entity.Position{}).
		Scopes(scopes...).
		Find(&positions)

	return positions, result.Error
}

func (r *positionRepository) Updates(v interface{}, id uuid.UUID) (int64, error) {
	result := r.db.
		Model(&entity.Position{}).
		Where("id = ?", id).
		Where("deleted_at IS NULL").
		Updates(v)

	return result.RowsAffected, result.Error
}

func (r *positionRepository) SoftDelete(id uuid.UUID) (int64, error) {
	result := r.db.
		Model(&entity.Position{}).
		Where("id = ?", id).
		Where("deleted_at IS NULL").
		Update("deleted_at", time.Now())

	return result.RowsAffected, result.Error
}

func (r *positionRepository) FindOne(where interface{}, args ...interface{}) (entity.Position, error) {
	var position entity.Position
	result := r.db.
		Where(where, args...).
		Where("deleted_at IS NULL").
		First(&position)
	return position, result.Error
}
