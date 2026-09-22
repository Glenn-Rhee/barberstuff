package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"errors"
	"fmt"
	"log"
	"os"
	"runtime"
	"time"

	"github.com/google/uuid"
	"github.com/joho/godotenv"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
)

type StaffService interface {
	CreateAdmin(req dto.StaffRequest) error
	CreateAccout(req dto.CreateAccountStaffRequest) error
	GetAccounts(query dto.QueryParamsAccountStaff) (*[]dto.StaffAccountsResponse, error)
	GetProfile(claims *lib.CustomClaims) (dto.StaffAccountsResponse, error)
	UpdateAccount(req dto.UpdateAccountStaffRequest, claims *lib.CustomClaims, idStaff string) error
	DeleteAccount(idStaff string, claims *lib.CustomClaims) error
	CreateBooking(claims *lib.CustomClaims, req dto.CreateCashireBookingRequest) error
	CheckinBooking(qrCode string) error
	AddItemBooking(req dto.BookingItemReq) error
	DeleteItemBooking(req dto.BookingItemReq) error
}

type staffService struct {
	staffRepo       repository.StaffRepository
	authRepo        repository.AuthenticationRepository
	storeRepo       repository.StoreRepository
	customerRepo    repository.CustomerRepository
	capsterRepo     repository.CapsterRepository
	bookingRepo     repository.BookingRepository
	serviceRepo     repository.ServiceRepository
	bookingItemRepo repository.BookingItemRepository
	db              *gorm.DB
}

func NewStaffService(
	str repository.StoreRepository,
	sr repository.StaffRepository,
	ar repository.AuthenticationRepository,
	cr repository.CustomerRepository,
	cpr repository.CapsterRepository,
	br repository.BookingRepository,
	svr repository.ServiceRepository,
	bi repository.BookingItemRepository,
	db *gorm.DB,
) StaffService {
	return &staffService{
		staffRepo:       sr,
		authRepo:        ar,
		db:              db,
		storeRepo:       str,
		customerRepo:    cr,
		capsterRepo:     cpr,
		bookingRepo:     br,
		serviceRepo:     svr,
		bookingItemRepo: bi,
	}
}

func (s *staffService) CreateAdmin(req dto.StaffRequest) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat data admin"
	_, filePath, _, _ := runtime.Caller(0)

	dataAuth, err := s.authRepo.FindOne("email = ?", req.Email)
	if err == nil {
		if dataAuth.Role != entity.RoleAdmin {
			return errors.New("Email ini telah terdaftar!")
		}

		return errors.New("Akun admin telah terdaftar! Tidak dapat mendaftar kembali")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find data staff", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	_, err = s.authRepo.FindOne("role = ?", entity.RoleAdmin)
	if err == nil {
		return errors.New("Akun admin telah terdaftar! Tidak dapat mendaftar kembali")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find data staff", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	hashedPassword, err := helper.HashPassword(req.Password)
	if err != nil {
		helper.Logger("Hashed password", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	tx := s.db.Begin()
	if tx.Error != nil {
		helper.Logger("Begin tx", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	adminId := uuid.New()

	admin := entity.Staff{
		ID:   adminId,
		Name: req.Name,
	}

	adminAuth := entity.Authentication{
		ID:         uuid.New(),
		IDStaff:    &adminId,
		Password:   hashedPassword,
		Role:       entity.RoleAdmin,
		Email:      req.Email,
		IsVerified: true,
		LoginType:  entity.LoginWithCredential,
	}

	err = s.staffRepo.Create(tx, &admin)
	if err != nil {
		tx.Rollback()
		helper.Logger("Create data staff", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	err = s.authRepo.Create(tx, &adminAuth)
	if err != nil {
		tx.Rollback()
		helper.Logger("Create data auth", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	tx.Commit()
	return nil
}

func (s *staffService) CreateAccout(req dto.CreateAccountStaffRequest) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat akun staff"
	_, filePath, _, _ := runtime.Caller(0)
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Println("Error load dotenv file:", err.Error())
		}
	}

	BASE_PASSWORD := os.Getenv("BASE_PASSWORD_STAFF")
	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return errors.New("Format id toko tidak valid!")
	}

	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Data toko cabang tidak ditemukan atau telah dihapus")
		}

		helper.Logger("Find data store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	dataAuth, err := s.authRepo.FindOne("email = ?", req.Email)

	if err == nil {
		if dataAuth.Role == req.Role {
			return errors.New("Email ini telah terdaftar!")
		}

		return errors.New("Akun staff telah terdaftar! Tidak dapat mendaftar kembali")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find data auth", filePath, err)
		return errors.New(BASE_MESSAGE)
	}
	var scopes []func(*gorm.DB) *gorm.DB
	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Where("staff.id_store = ?", dataStore.ID)
	})
	dataStaffes, err := s.staffRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("Find all staff", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if len(dataStaffes) >= 2 {
		return errors.New("Batas akun toko penuh (maks. 2 akun)")
	}

	var isRegistered bool = false
	for _, v := range dataStaffes {
		if v.Authentication.Role == req.Role {
			isRegistered = true
		}
	}

	if isRegistered {
		return fmt.Errorf("Role %s untuk toko %s telah terdaftar", req.Role, dataStore.Name)
	}

	hashedPassword, err := helper.HashPassword(BASE_PASSWORD)
	if err != nil {
		helper.Logger("Hash password", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	err = s.db.Transaction(func(tx *gorm.DB) error {
		newStaff := entity.Staff{
			ID:      uuid.New(),
			Name:    req.Name,
			IdStore: &idStore,
		}

		if err := tx.Create(&newStaff).Error; err != nil {
			return err
		}

		newAuth := entity.Authentication{
			ID:         uuid.New(),
			IDStaff:    &newStaff.ID,
			Password:   hashedPassword,
			Role:       req.Role,
			Email:      req.Email,
			IsVerified: true,
			LoginType:  entity.LoginWithCredential,
		}

		if err := tx.Create(&newAuth).Error; err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		helper.Logger("Creattae staff and auth", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *staffService) GetAccounts(query dto.QueryParamsAccountStaff) (*[]dto.StaffAccountsResponse, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data akun staff"
	_, filePath, _, _ := runtime.Caller(0)

	idStore, err := uuid.Parse(query.IdStore)
	if err != nil {
		return &[]dto.StaffAccountsResponse{}, errors.New("Id toko cabang tidak valid")
	}

	_, err = s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return &[]dto.StaffAccountsResponse{}, errors.New("Toko tidak ditemukan atau sudah dihapus.")
		}

		helper.Logger("Find data store", filePath, err)
		return &[]dto.StaffAccountsResponse{}, errors.New(BASE_MESSAGE)
	}
	var scopes []func(*gorm.DB) *gorm.DB
	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Where("staff.id_store = ?", idStore)
	})

	if query.Email != nil {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			q := "%"
			q += *query.Email
			q += "%"
			return d.Joins("JOIN authentication ON authentication.id_staff = staff.id").
				Where("authentication.email ILIKE ?", q)
		})
	}

	if query.Name != nil {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			q := "%"
			q += *query.Name
			q += "%"
			return d.Where("staff.name = ?", q)
		})
	}

	dataStaffes, err := s.staffRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("Fin all data staff", filePath, err)
		return &[]dto.StaffAccountsResponse{}, errors.New(BASE_MESSAGE)
	}

	var dataResults = make([]dto.StaffAccountsResponse, 0)

	for _, v := range dataStaffes {
		avgRating := float32(5.0)
		totalRating := 0
		for _, r := range v.Ratings {
			totalRating += int(r.Score)
		}

		if len(v.Ratings) > 0 {
			avgRating = float32(totalRating) / float32(len(v.Ratings))
		}

		dataResults = append(dataResults, dto.StaffAccountsResponse{
			Id:        v.ID,
			Name:      v.Name,
			IdStore:   *v.IdStore,
			Role:      v.Authentication.Role,
			Email:     v.Authentication.Email,
			CreatedAt: v.CreatedAt,
			AvgRating: avgRating,
		})
	}

	return &dataResults, nil
}

func (s *staffService) GetProfile(claims *lib.CustomClaims) (dto.StaffAccountsResponse, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengambil data akun staff"
	_, filePath, _, _ := runtime.Caller(0)

	dataStaff, err := s.staffRepo.FindProfile(claims.UserId)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return dto.StaffAccountsResponse{}, errors.New("Profile tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("Find data staff", filePath, err)
		return dto.StaffAccountsResponse{}, errors.New(BASE_MESSAGE)
	}

	if claims.Role != entity.RoleAdmin {
		_, err = s.storeRepo.FindOne("id = ?", dataStaff.IdStore)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return dto.StaffAccountsResponse{}, errors.New("Data toko tidak ditemukan atau telah dihapus")
			}

			helper.Logger("Find data staff", filePath, err)
			return dto.StaffAccountsResponse{}, errors.New(BASE_MESSAGE)
		}
	}

	var idStore uuid.UUID

	if claims.Role != entity.RoleAdmin {
		idStore = *dataStaff.IdStore
	}

	dataResult := dto.StaffAccountsResponse{
		Id:        dataStaff.ID,
		Name:      dataStaff.Name,
		IdStore:   idStore,
		Role:      dataStaff.Authentication.Role,
		Email:     dataStaff.Authentication.Email,
		CreatedAt: dataStaff.CreatedAt,
	}

	return dataResult, nil
}

func (s *staffService) UpdateAccount(req dto.UpdateAccountStaffRequest, claims *lib.CustomClaims, idStaff string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengupdate data toko!"
	_, filePath, _, _ := runtime.Caller(0)

	id, err := uuid.Parse(idStaff)
	if err != nil {
		return errors.New("Id staff tidak valid!")
	}

	dataStaff, err := s.staffRepo.FindOne("id = ?", id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Data staff yang anda ingin ubah tidak ditemukan atau telah dihapus")
		}

		helper.Logger("Find data staff", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if claims.Role != entity.RoleAdmin && idStaff != claims.UserId {
		return errors.New("Oops! Anda tidak bisa mengubah data milik orang lain")
	}

	hashedPassword, err := helper.HashPassword(req.Password)
	if err != nil {
		helper.Logger("Hash password", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	err = s.db.Transaction(func(tx *gorm.DB) error {
		var scopesEdit []func(*gorm.DB) *gorm.DB
		scopesEdit = append(scopesEdit, func(d *gorm.DB) *gorm.DB {
			return d.Where("id = ?", id)
		})
		rowsAffected, err := s.staffRepo.Updates(map[string]interface{}{
			"name": req.Name,
		}, scopesEdit...)

		if err != nil {
			return err
		}

		if rowsAffected == 0 {
			return errors.New("Data staff yang anda ingin ubah tidak ditemukan atau telah dihapus")
		}

		err = s.authRepo.Updates(map[string]interface{}{
			"password": hashedPassword,
		}, dataStaff.Authentication.ID)

		if err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		helper.Logger("Update data account", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *staffService) DeleteAccount(idStaff string, claims *lib.CustomClaims) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengupdate data toko!"
	_, filePath, _, _ := runtime.Caller(0)

	id, err := uuid.Parse(idStaff)
	if err != nil {
		return errors.New("Id staff tidak valid!")
	}

	if claims.UserId == idStaff {
		return errors.New("Oops! Anda tidak dapat menghapus diri sendiri!")
	}

	_, err = s.staffRepo.FindOne("id = ?", id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Data akun tidak ditemukan atau telah dihapus!")
		}
		helper.Logger("Find one data", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	err = s.staffRepo.SoftDelete(id)
	if err != nil {
		helper.Logger("Delete data", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *staffService) CreateBooking(claims *lib.CustomClaims, req dto.CreateCashireBookingRequest) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat booking. Coba lagi nanti!"
	const BUSY_WINDOW = 1 * time.Hour // FIX: jendela waktu dianggap "masih sibuk"
	_, filePath, _, _ := runtime.Caller(0)

	idStaff, err := uuid.Parse(claims.UserId)
	if err != nil {
		return errors.New("Data Anda tidak valid. Mohon login ulang.")
	}

	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return errors.New("Data Toko tidak valid.")
	}

	idCapster, err := uuid.Parse(req.IdCapster)
	if err != nil {
		return errors.New("Data Capster tidak valid.")
	}

	idServices := make([]uuid.UUID, 0, len(req.IdServices))
	isIdServiceValid := true
	for _, id := range req.IdServices {
		idService, err := uuid.Parse(id)
		if err != nil {
			isIdServiceValid = false
			break
		}

		idServices = append(idServices, idService)
	}

	if len(idServices) == 0 {
		return errors.New("Pilih setidaknya satu data service")
	}

	if !isIdServiceValid {
		return errors.New("Data service tidak valid. Periksa kembali data Anda.")
	}

	if helper.IsAllFieldsNil(req.Customer) {
		return errors.New("Masukkan setidaknya salah satu identitas data customer.")
	}

	var idCustomer uuid.UUID
	if req.Customer.Id != nil {
		// Punya aplikassi
		id, err := uuid.Parse(*req.Customer.Id)
		if err != nil {
			return errors.New("Data id customer tidak valid.")
		}
		dataCustomer, err := s.customerRepo.FindOne("id = ?", id)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return errors.New("Data customer tidak ditemukaan atau telah dihapus.")
			}

			helper.Logger("find one customer", filePath, err)
			return errors.New(BASE_MESSAGE)
		}

		idCustomer = dataCustomer.ID
	} else {
		// Gapunya aplikassi
		if (req.Customer.Name != nil && req.Customer.PhoneNumber == nil) || (req.Customer.Name == nil && req.Customer.PhoneNumber != nil) {
			return errors.New("Nama dan no telpon wajib diisi untuk membuat customer baru")
		}

		dataCustomer, err := s.customerRepo.FindOne("phone_number = ?", *req.Customer.PhoneNumber)
		if err == nil {
			idCustomer = dataCustomer.ID
		} else {
			if !errors.Is(err, gorm.ErrRecordNotFound) {
				helper.Logger("find one customer by phone number", filePath, err)
				return errors.New(BASE_MESSAGE)
			}

			newCustomer := entity.Customer{
				ID:           uuid.New(),
				Name:         *req.Customer.Name,
				PhoneNumber:  req.Customer.PhoneNumber,
				MemberPoints: 0,
				Gender:       entity.GenderOther,
			}

			err = s.db.Transaction(func(tx *gorm.DB) error {
				err = s.customerRepo.Create(tx, &newCustomer)
				return err
			})

			if err != nil {
				helper.Logger("create new customer", filePath, err)
				return errors.New(BASE_MESSAGE)
			}

			idCustomer = newCustomer.ID
		}

	}

	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("find one store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	loc, err := time.LoadLocation(string(dataStore.Timezone))
	if err != nil {
		helper.Logger("load timezone", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	now := time.Now().In(loc)
	scheduledAt := req.BookingDate.In(loc)

	if scheduledAt.Before(now) {
		return errors.New("Tanggal dan jam booking tidak boleh kurang dari waktu sekarang")
	}

	_, err = s.capsterRepo.FindOne(&entity.Capster{ID: idCapster, Status: entity.CapsterStatusActive, IDStore: idStore})
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Capster tidak ditemukan atau telah dihapus!")
		}

		helper.Logger("find one capster", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	_, err = s.bookingRepo.FindOne(
		"id_user = ? AND status_booking IN ?",
		idCustomer,
		[]entity.BookingStatusEnum{entity.BookingStatusBooked, entity.BookingStatusProgress},
	)

	if err == nil {
		return errors.New("Customer ini telah memiliki booking. Selesaikan booking terlebih dahulu.")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("Find one booking", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	var scopeActiveBookings []func(*gorm.DB) *gorm.DB
	scopeActiveBookings = append(scopeActiveBookings, func(d *gorm.DB) *gorm.DB {
		return d.
			Where("id_store = ?", idStore).
			Where("status_booking IN ?", []entity.BookingStatusEnum{
				entity.BookingStatusBooked,
				entity.BookingStatusProgress,
			})
	})

	dataActiveBookings, err := s.bookingRepo.FindAll(scopeActiveBookings...)
	if err != nil {
		helper.Logger("find all active booking by store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	busyCapsterSet := make(map[uuid.UUID]bool)
	for _, v := range dataActiveBookings {
		existingTime := v.ScheduledAt.In(loc)
		diff := existingTime.Sub(scheduledAt)
		if diff < 0 {
			diff = -diff
		}

		if diff < BUSY_WINDOW {
			busyCapsterSet[v.IDCapster] = true
		}
	}

	var scopesActiveCapster []func(*gorm.DB) *gorm.DB
	scopesActiveCapster = append(scopesActiveCapster, func(d *gorm.DB) *gorm.DB {
		return d.
			Where("id_store = ?", idStore).
			Where("status = ?", entity.CapsterStatusActive)
	})

	dataCapsters, err := s.capsterRepo.FindAll(scopesActiveCapster...)
	if err != nil {
		helper.Logger("find all capsters", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	var freeCapsterIDs []uuid.UUID
	for _, c := range dataCapsters {
		if !busyCapsterSet[c.ID] {
			freeCapsterIDs = append(freeCapsterIDs, c.ID)
		}
	}

	if len(freeCapsterIDs) == 0 {
		return errors.New("Sudah tidak ada lagi capster yang tersedia.")
	}

	if busyCapsterSet[idCapster] {
		return errors.New("Capster ini sedang tidak tersedia pada rentang waktu tersebut.")
	}

	var scopesService []func(*gorm.DB) *gorm.DB
	scopesService = append(scopesService, func(d *gorm.DB) *gorm.DB {
		return d.Where("id IN ? AND status = ? AND id_store = ?", idServices, entity.ProductStatusActive, idStore)
	})

	dataServices, err := s.serviceRepo.FindAll(scopesService...)
	if err != nil {
		helper.Logger("find all services", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if len(dataServices) == 0 {
		return errors.New("Data service tidak ada yang ditemukan.")
	}

	var subTotal decimal.Decimal = decimal.Zero
	idBooking := uuid.New()
	bookingItems := make([]entity.BookingItem, 0, len(dataServices))
	for _, v := range dataServices {
		subTotal = subTotal.Add(v.Price)
		bookingItems = append(bookingItems, entity.BookingItem{
			ID:          uuid.New(),
			IDBooking:   idBooking,
			IDService:   v.ID,
			Price:       v.Price,
			AddedOnSpot: true,
		})
	}

	totalPrice := subTotal

	statusBooking := entity.BookingStatusBooked
	bookingType := entity.BookingScheduled
	if req.BookingType == dto.BookingTypeOrder {
		statusBooking = entity.BookingStatusProgress
		bookingType = entity.BookingWalkIn
	}

	qrCode := fmt.Sprintf("bk%v", idBooking)
	data := entity.Booking{
		ID:             idBooking,
		StatusBooking:  statusBooking,
		IDStore:        idStore,
		IDCustomer:     idCustomer,
		IDCapster:      idCapster,
		IDStaff:        idStaff,
		SubTotal:       subTotal,
		DiscountAmount: decimal.Zero,
		TotalPrice:     totalPrice,
		ScheduledAt:    scheduledAt,
		QRCode:         qrCode,
		BookingType:    bookingType,
		BookingItems:   bookingItems,
	}

	err = s.db.Transaction(func(tx *gorm.DB) error {
		return s.bookingRepo.Create(tx, &data)
	})

	if err != nil {
		helper.Logger("Create data booking", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *staffService) CheckinBooking(qrCode string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat checkin. Mohon coba lagi nanti"
	_, filePath, _, _ := runtime.Caller(0)

	// Cek capsternya bisa di checkin atau engga klo checkin di luar dari jam
	dataBooking, err := s.bookingRepo.FindOne("qr_code = ?", qrCode)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Booking tidak ditemukan.")
		}
		helper.Logger("find one booking", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	dataStore, err := s.storeRepo.FindOne("id = ?", dataBooking.IDStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko tidak ditemukan.")
		}
		helper.Logger("find one toko", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	loc, err := time.LoadLocation(string(dataStore.Timezone))
	if err != nil {
		helper.Logger("load timezone", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	now := time.Now().In(loc)
	closeToday := time.Date(
		now.Year(), now.Month(), now.Day(),
		dataStore.CloseHour.Hour(), dataStore.CloseHour.Minute(), 0, 0,
		loc,
	)

	checkinDeadline := closeToday.Add(-30 * time.Minute)

	if now.After(checkinDeadline) {
		return errors.New("Checkin tidak dapat dilakukan, waktu sudah mendekati jam tutup toko.")
	}

	var scopesGetAll []func(*gorm.DB) *gorm.DB
	scopesGetAll = append(scopesGetAll, func(d *gorm.DB) *gorm.DB {
		statusBooking := []entity.BookingStatusEnum{
			entity.BookingStatusBooked,
			entity.BookingStatusProgress,
		}

		oneHourLater := now.Add(1 * time.Hour)
		return d.Where("id_capster = ? AND status_booking IN ? AND id_store = ? AND scheduled_at >= ? AND scheduled_at <= ? AND id != ?",
			dataBooking.IDCapster,
			statusBooking,
			dataBooking.IDStore,
			now,
			oneHourLater,
			dataBooking.ID,
		)
	})

	dataBookings, err := s.bookingRepo.FindAll(scopesGetAll...)
	if err != nil {
		helper.Logger("find all booking", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if len(dataBookings) > 0 {
		return errors.New("Tidak dapat checkin. Capster sedang sibuk.")
	}

	var scopesUpdate []func(*gorm.DB) *gorm.DB
	scopesUpdate = append(scopesUpdate, func(d *gorm.DB) *gorm.DB {
		return d.Where("qr_code = ? AND status_booking = ?", qrCode, entity.BookingStatusBooked)
	})

	rowsAffected, err := s.bookingRepo.Updates(map[string]interface{}{
		"status_booking": entity.BookingStatusProgress,
	}, scopesUpdate...)

	if err != nil {
		helper.Logger("update status booking", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if rowsAffected == 0 {
		return errors.New("Booking tidak ditemukan atau telah checkin sebelumnya.")
	}

	return nil
}

func (s *staffService) AddItemBooking(req dto.BookingItemReq) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat checkin. Mohon coba lagi nanti"
	_, filePath, _, _ := runtime.Caller(0)

	idBooking, err := uuid.Parse(req.IdBooking)
	if err != nil {
		return errors.New("Id booking tidak valid!")
	}

	idService, err := uuid.Parse(req.IdService)
	if err != nil {
		return errors.New("Id service tidak valid!")
	}

	dataBooking, err := s.bookingRepo.FindOne("id = ?", idBooking)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Booking tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("find one booking", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if dataBooking.StatusBooking != entity.BookingStatusProgress {
		return errors.New("Tidak dapat menambahkan item, hanya dapat dilakukan saat booking berlangsung.")
	}

	dataService, err := s.serviceRepo.FindOne("id = ?", idService)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Service tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("find one service", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	isBookingItemRegist := false
	for _, v := range dataBooking.BookingItems {
		if v.IDService == idService && dataBooking.ID == idBooking {
			isBookingItemRegist = true
			break
		}
	}

	if isBookingItemRegist {
		return errors.New("Service ini telah ditambahkan.")
	}

	dataBookingItem := entity.BookingItem{
		ID:          uuid.New(),
		IDBooking:   idBooking,
		IDService:   idService,
		Price:       dataService.Price,
		AddedOnSpot: true,
	}

	err = s.db.Transaction(func(tx *gorm.DB) error {
		if err := s.bookingItemRepo.Create(tx, &dataBookingItem); err != nil {
			return err
		}

		result := tx.Model(&entity.Booking{}).
			Where("id = ?", idBooking).
			Updates(map[string]interface{}{
				"subtotal":    gorm.Expr("subtotal + ?", dataBookingItem.Price),
				"total_price": gorm.Expr("subtotal + ? - discount_amount", dataBookingItem.Price),
			})

		if result.Error != nil {
			return result.Error
		}
		if result.RowsAffected == 0 {
			return errors.New("data booking tidak ditemukan")
		}
		return nil
	})

	if err != nil {
		helper.Logger("create data service", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *staffService) DeleteItemBooking(req dto.BookingItemReq) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat checkin. Mohon coba lagi nanti"
	_, filePath, _, _ := runtime.Caller(0)

	idBooking, err := uuid.Parse(req.IdBooking)
	if err != nil {
		return errors.New("Id booking tidak valid!")
	}

	idService, err := uuid.Parse(req.IdService)
	if err != nil {
		return errors.New("Id service tidak valid!")
	}

	dataBooking, err := s.bookingRepo.FindOne("id = ?", idBooking)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Booking tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("find one booking", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if len(dataBooking.BookingItems) <= 1 {
		return errors.New("Customer wajib memiliki setidaknya 1 service/paket.")
	}

	if dataBooking.StatusBooking != entity.BookingStatusProgress {
		return errors.New("Tidak dapat menghapus item, hanya dapat dilakukan saat booking berlangsung.")
	}

	_, err = s.serviceRepo.FindOne("id = ?", idService)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Service tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("find one service", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	rowsAffected, err := s.bookingItemRepo.Delete("id_service = ? AND id_booking = ?", idService, idBooking)
	if err != nil {
		helper.Logger("delete booking item", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if rowsAffected == 0 {
		return errors.New("Data booking item tidak dapat dihapus.")
	}

	return nil
}
