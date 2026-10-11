package repository

import (
	"barberstuff_backend/internal/entity"

	"gorm.io/gorm"
)

type PositionRepository interface {
	Create(p *entity.Position) error
	FindAll(scopes ...func(*gorm.DB) *gorm.DB) ([]entity.Position, error)
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
