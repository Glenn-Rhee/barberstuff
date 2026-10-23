package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/repository"
	"encoding/json"
	"errors"
	"runtime"
	"strings"
	"unicode/utf8"

	"github.com/google/uuid"
	"gorm.io/datatypes"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type NotificationService interface {
	Notify(tx *gorm.DB, in dto.NotifyInput) (dto.NotifyResult, error)
}

type notificationService struct {
	notifRepo    repository.NotificationRepository
	deliveryRepo repository.NotificationDeliveryRepository
	deviceRepo   repository.DeviceTokenRepository
	txManager    repository.TxManager
}

var ErrInvalidNotification = errors.New("notification: input tidak valid")

func NewNotificationService(
	nr repository.NotificationRepository,
	dr repository.NotificationDeliveryRepository,
	dvr repository.DeviceTokenRepository,
	tm repository.TxManager,
) NotificationService {
	return &notificationService{
		notifRepo:    nr,
		deliveryRepo: dr,
		deviceRepo:   dvr,
		txManager:    tm,
	}
}

func (s *notificationService) Notify(tx *gorm.DB, in dto.NotifyInput) (dto.NotifyResult, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat notifikasi!"
	_, filePath, _, _ := runtime.Caller(0)
	in.EventType = strings.TrimSpace(in.EventType)
	in.Title = strings.TrimSpace(in.Title)
	in.Body = strings.TrimSpace(in.Body)
	in.DedupKey = strings.TrimSpace(in.DedupKey)

	if err := validateNotifyInput(in); err != nil {
		return dto.NotifyResult{}, err
	}

	data := datatypes.JSON("{}")
	if len(in.Data) > 0 {
		b, err := json.Marshal(in.Data)
		if err != nil {
			return dto.NotifyResult{}, ErrInvalidNotification
		}

		data = b
	}

	var dedupKey *string
	if in.DedupKey != "" {
		dedupKey = &in.DedupKey
	}

	var result dto.NotifyResult
	run := func(tx *gorm.DB) error {
		n := entity.Notification{
			ID:         uuid.New(),
			IdUser:     in.IdUser,
			IdCampaign: in.IdCampaign,
			EventType:  in.EventType,
			Title:      in.Title,
			Body:       in.Body,
			Data:       data,
			DedupKey:   dedupKey,
		}

		inserted, err := s.notifRepo.CreateBatch(
			tx, []entity.Notification{n}, 1,
			clause.OnConflict{DoNothing: true},
		)

		if err != nil {
			return err
		}

		if inserted == 0 {
			return nil
		}

		result.Created = true
		result.ID = n.ID

		devices, err := s.deviceRepo.FindAll(func(d *gorm.DB) *gorm.DB {
			return d.Where("id_user = ? AND is_active = TRUE", in.IdUser)
		})

		if err != nil {
			return err
		}

		if len(devices) == 0 {
			return nil
		}

		deliveries := make([]entity.NotificationDelivery, 0, len(devices))
		for _, v := range devices {
			deliveries = append(deliveries, entity.NotificationDelivery{
				ID:             uuid.New(),
				IdNotification: n.ID,
				IdDeviceToken:  v.ID,
				Status:         entity.DeliveryStatusPending,
				Attempts:       0,
			})
		}

		if err := s.deliveryRepo.CreateBatch(tx, deliveries, 500); err != nil {
			return err
		}

		result.Deliveries = len(deliveries)
		return nil
	}

	var err error
	if tx != nil {
		err = run(tx)
	} else {
		err = s.txManager.Transaction(run)
	}

	if err != nil {
		helper.Logger("Create notify", filePath, err)
		return dto.NotifyResult{}, errors.New(BASE_MESSAGE)
	}

	return result, nil
}

func validateNotifyInput(in dto.NotifyInput) error {
	switch {
	case in.IdUser == uuid.Nil:
		return errors.Join(ErrInvalidNotification, errors.New("id user kosong"))
	case in.EventType == "" || utf8.RuneCountInString(in.EventType) > 50:
		return errors.Join(ErrInvalidNotification, errors.New("event type kosong atau > 50"))
	case in.Title == "" || utf8.RuneCountInString(in.Title) > 150:
		return errors.Join(ErrInvalidNotification, errors.New("Title kosong atau > 150"))
	case in.Body == "":
		return errors.Join(ErrInvalidNotification, errors.New("body kosong"))
	case utf8.RuneCountInString(in.DedupKey) > 150:
		return errors.Join(ErrInvalidNotification, errors.New("dedup key > 150"))
	}

	return nil
}
