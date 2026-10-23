package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/infra/fcm"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"runtime"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/google/uuid"
	"gorm.io/datatypes"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type NotificationService interface {
	Notify(tx *gorm.DB, in dto.NotifyInput) (dto.NotifyResult, error)
	DispatchPending(ctx context.Context, limit int) (int, error)
	GetNotifications(req dto.GetNotificationReq, claims *lib.CustomClaims) (dto.GetNotificationRes, dto.ResponsePagination, error)
}

type notificationService struct {
	notifRepo    repository.NotificationRepository
	deliveryRepo repository.NotificationDeliveryRepository
	deviceRepo   repository.DeviceTokenRepository
	txManager    repository.TxManager
	sender       fcm.Sender
	maxAttempts  int16
}

var ErrInvalidNotification = errors.New("notification: input tidak valid")

func NewNotificationService(
	nr repository.NotificationRepository,
	dr repository.NotificationDeliveryRepository,
	dvr repository.DeviceTokenRepository,
	tm repository.TxManager,
	sender fcm.Sender,
) NotificationService {
	return &notificationService{
		notifRepo:    nr,
		deliveryRepo: dr,
		deviceRepo:   dvr,
		txManager:    tm,
		sender:       sender,
		maxAttempts:  3,
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

func (s *notificationService) DispatchPending(ctx context.Context, limit int) (int, error) {
	if limit <= 0 {
		limit = 50
	}

	processed := 0

	err := s.txManager.Transaction(func(tx *gorm.DB) error {
		statusQ := []entity.StatusNotificationDeliveryEnum{
			entity.DeliveryStatusFailed,
			entity.DeliveryStatusPending,
		}
		deliveries, err := s.deliveryRepo.FindAll(tx, func(d *gorm.DB) *gorm.DB {
			return d.Clauses(clause.Locking{Strength: "UPDATE", Options: "SKIP LOCKED"}).
				Where("status IN ? AND attempts < ?", statusQ, s.maxAttempts).
				Order("created_at ASC").
				Limit(limit)
		})

		if err != nil {
			return err
		}

		if len(deliveries) == 0 {
			return nil
		}

		notifIDs := make([]uuid.UUID, 0, len(deliveries))
		deviceIDs := make([]uuid.UUID, 0, len(deliveries))
		for _, d := range deliveries {
			notifIDs = append(notifIDs, d.IdNotification)
			deviceIDs = append(deviceIDs, d.IdDeviceToken)
		}

		notifList, err := s.notifRepo.FindAll(tx, func(d *gorm.DB) *gorm.DB {
			return d.Where("id IN ?", notifIDs)
		})

		if err != nil {
			{
				return err
			}
		}

		deviceList, err := s.deviceRepo.FindAll(func(d *gorm.DB) *gorm.DB {
			return d.Where("id IN ?", deviceIDs)
		})

		if err != nil {
			return err
		}

		notifMap := make(map[uuid.UUID]entity.Notification, len(notifList))
		for _, n := range notifList {
			notifMap[n.ID] = n
		}

		deviceMap := make(map[uuid.UUID]entity.DeviceToken, len(deviceList))
		for _, d := range deviceList {
			deviceMap[d.ID] = d
		}

		for _, del := range deliveries {
			if ctx.Err() != nil {
				return ctx.Err()
			}

			processed++

			n, okN := notifMap[del.IdNotification]
			dev, okD := deviceMap[del.IdDeviceToken]

			switch {
			case !okN:
				if err := s.markDelivery(tx, del.ID, entity.DeliveryStatusFailed, "", "notifikasi tidak ditemukan", true); err != nil {
					return err
				}
				continue
			case !okD || !dev.IsActive:
				if err := s.markDelivery(tx, del.ID, entity.DeliveryStatusInvalidToken, "", "device tidak aktif", false); err != nil {
					return err
				}
				continue
			}

			msgID, sendErr := s.sender.Send(ctx, fcm.Message{
				Token: dev.FcmToken,
				Title: n.Title,
				Body:  n.Body,
				Data:  buildFCMData(n),
			})

			var markErr error
			switch {
			case sendErr == nil:
				markErr = s.markDelivery(tx, del.ID, entity.DeliveryStatusSent, msgID, "", false)

			case errors.Is(sendErr, fcm.ErrInvalidToken):
				markErr = s.markDelivery(tx, del.ID, entity.DeliveryStatusInvalidToken, "", sendErr.Error(), false)
				if markErr == nil {
					_, markErr = s.deviceRepo.Deactive(
						map[string]interface{}{"is_active": false},
						func(d *gorm.DB) *gorm.DB {
							return d.Where("id = ?", dev.ID)
						},
					)
				}

			case errors.Is(sendErr, fcm.ErrPermanent):
				markErr = s.markDelivery(tx, del.ID, entity.DeliveryStatusFailed, "", sendErr.Error(), true)

			default:
				markErr = s.markDelivery(tx, del.ID, entity.DeliveryStatusFailed, "", sendErr.Error(), false)
			}

			if markErr != nil {
				return markErr
			}
		}

		return nil
	})

	if err != nil {
		return 0, err
	}

	return processed, nil
}

func (s *notificationService) GetNotifications(req dto.GetNotificationReq, claims *lib.CustomClaims) (dto.GetNotificationRes, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data notifikasi!"
	_, filePath, _, _ := runtime.Caller(0)

	idUser, err := uuid.Parse(claims.UserId)
	if err != nil {
		return dto.GetNotificationRes{}, dto.ResponsePagination{}, errors.New("Data tidak valid. Mohon registrasi ulang.")
	}

	totalUnread, err := s.notifRepo.Count(nil, func(d *gorm.DB) *gorm.DB {
		return d.Where("is_read = FALSE")
	})

	if err != nil {
		helper.Logger("count unread data", filePath, err)
		return dto.GetNotificationRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	var scopes []func(*gorm.DB) *gorm.DB
	if req.Query != nil {
		q := "%" + *req.Query + "%"
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("event_type ILIKE ? OR title ILIKE ? OR body ILIKE ?", q, q, q)
		})
	}

	var page = 1
	var limit = 20
	var orderBy = dto.OrderDesc

	if req.Page != nil {
		page = *req.Page
	}

	if req.Limit != nil {
		limit = *req.Limit
	}

	if req.OrderBy != nil {
		orderBy = *req.OrderBy
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Where("id_user = ?", idUser)
	})

	totalData, err := s.notifRepo.Count(nil, scopes...)
	if err != nil {
		helper.Logger("count notif", filePath, err)
		return dto.GetNotificationRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Clauses(clause.OrderBy{
			Columns: []clause.OrderByColumn{
				{Column: clause.Column{Name: "is_read"}, Desc: orderBy == dto.OrderDesc},
				{Column: clause.Column{Name: "created_at"}, Desc: true},
			},
		}).Offset((page - 1) * limit).Limit(limit)
	})

	paginationData := helper.GetPaginationData(page, limit, int(totalData))
	notifications, err := s.notifRepo.FindAll(nil, scopes...)
	if err != nil {
		helper.Logger("find all notif", filePath, err)
		return dto.GetNotificationRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	dataNotif := make([]dto.NotificationData, 0, len(notifications))
	for _, v := range notifications {
		dataNotif = append(dataNotif, dto.NotificationData{
			ID:        v.ID,
			EventType: v.EventType,
			Title:     v.Title,
			Body:      v.Body,
			Data:      v.Data,
			IsRead:    v.IsRead,
			ReadAt:    v.ReadAt,
			CreatedAt: v.CreatedAt,
		})
	}

	return dto.GetNotificationRes{
		Notifications: dataNotif,
		TotalUnread:   totalUnread,
	}, paginationData, nil
}

func buildFCMData(n entity.Notification) map[string]string {
	out := map[string]string{"notification_id": n.ID.String()}
	var raw map[string]interface{}

	if len(n.Data) > 0 && json.Unmarshal(n.Data, &raw) == nil {
		for k, v := range raw {
			if str, ok := v.(string); ok {
				out[k] = str
			} else {
				out[k] = fmt.Sprint(v)
			}
		}
	}

	out["notification_id"] = n.ID.String()
	return out
}

func (s *notificationService) markDelivery(
	tx *gorm.DB, id uuid.UUID, status entity.StatusNotificationDeliveryEnum,
	providerMsgID, errMsg string, exhaust bool,
) error {
	v := map[string]interface{}{"status": status}

	if exhaust {
		v["attempts"] = s.maxAttempts
	} else {
		v["attempts"] = gorm.Expr("attempts + 1")
	}

	if status == entity.DeliveryStatusSent {
		v["provider_message_id"] = providerMsgID
		v["sent_at"] = time.Now()
		v["error"] = nil
	} else {
		v["error"] = truncate(errMsg, 500)
	}

	_, err := s.deliveryRepo.Updates(tx, v, func(d *gorm.DB) *gorm.DB {
		return d.Where("id = ?", id)
	})

	return err
}

func truncate(s string, max int) string {
	r := []rune(s)
	if len(r) <= max {
		return s
	}

	return string(r[:max])
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
