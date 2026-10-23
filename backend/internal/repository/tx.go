package repository

import "gorm.io/gorm"

type TxManager interface {
	Transaction(fn func(tx *gorm.DB) error) error
}

type txManager struct {
	db *gorm.DB
}

func NewTxManager(db *gorm.DB) TxManager {
	return &txManager{db: db}
}

func (m *txManager) Transaction(fn func(tx *gorm.DB) error) error {
	return m.db.Transaction(fn)
}

func conn(db, tx *gorm.DB) *gorm.DB {
	if tx != nil {
		return tx
	}

	return db
}
