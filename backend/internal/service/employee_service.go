package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"context"
	"errors"
	"fmt"
	"regexp"
	"runtime"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/shopspring/decimal"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type EmployeeService interface {
	CreateEmployee(ctx context.Context, req dto.CreateEmployeeReq) error
	GetEmployees(req dto.GetEmployeeReq, claims *lib.CustomClaims) (dto.GetEmployeeRes, dto.ResponsePagination, error)
	PatchEmployee(ctx context.Context, req dto.PatchEmployeeReq, id string) error
	SoftDeleteEmployee(id string) error
	Absent(req dto.CreateAbsentReq) error
	GetEmployeeAbsent(req dto.GetEmployeeAbsentReq) ([]dto.GetEmployeeAbsentRes, error)
}

type employeeService struct {
	employeeRepo repository.EmployeeRepository
	positionRepo repository.PositionRepository
	storeRepo    repository.StoreRepository
	absentRepo   repository.AbsentRepository
	staffRepo    repository.StaffRepository
	db           *gorm.DB
}

func NewEmployeeService(
	er repository.EmployeeRepository,
	pr repository.PositionRepository,
	sr repository.StoreRepository,
	ar repository.AbsentRepository,
	str repository.StaffRepository,
	d *gorm.DB,
) EmployeeService {
	return &employeeService{
		employeeRepo: er,
		positionRepo: pr,
		storeRepo:    sr,
		absentRepo:   ar,
		staffRepo:    str,
		db:           d,
	}
}

var (
	errPhoneTaken      = errors.New("nomor telepon sudah terdaftar")
	errEmailTaken      = errors.New("email sudah terdaftar")
	errNationalIDTaken = errors.New("NIK sudah terdaftar")
	errEmployeeExists  = errors.New("data karyawan sudah terdaftar")
)

var employeeUniqueErrors = map[string]error{
	"employee_phone_number_unique":       errPhoneTaken,
	"email_employee_unique":              errEmailTaken,
	"national_id_number_employee_unique": errNationalIDTaken,
}

func (s *employeeService) validateAgeEmployee(dateOfBirth time.Time) bool {
	now := time.Now()

	age := now.Year() - dateOfBirth.Year()

	if now.Month() < dateOfBirth.Month() ||
		(now.Month() == dateOfBirth.Month() &&
			now.Day() < dateOfBirth.Day()) {
		age--
	}

	return age >= 20 && age <= 35
}

func (s *employeeService) isValidAccountNumber(str string) bool {
	var accRe = regexp.MustCompile(`^\d{8,20}$`)

	return accRe.MatchString(strings.TrimSpace(str))
}

func rollbackFiles(ctx context.Context, keys ...*string) {
	for _, k := range keys {
		if k == nil {
			continue
		}
		if err := lib.MoveObjectToTemp(ctx, *k); err != nil {
			helper.Logger("rollback file to temp", "CreateEmployee", err)
		}
	}
}

func (s *employeeService) CreateEmployee(ctx context.Context, req dto.CreateEmployeeReq) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat karyawan baru."
	_, filePath, _, _ := runtime.Caller(0)

	if !s.validateAgeEmployee(req.DateOfBirth) {
		return errors.New("Minimum usia adalah 20 tahun & max usia 35 tahun.")
	}

	req.NationalIdNumber = strings.TrimSpace(req.NationalIdNumber)
	if _, err := helper.ValidateIdentityNumber(req.NationalIdNumber); err != nil {
		return err
	}

	req.AccountNumber = strings.TrimSpace(req.AccountNumber)
	if !s.isValidAccountNumber(req.AccountNumber) {
		return errors.New("Periksa no rekening yang benar.")
	}

	idPosition, err := uuid.Parse(req.IdPosition)
	if err != nil {
		return errors.New("Posisi id tidak valid.")
	}

	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return errors.New("Id toko tidak valid.")
	}

	// key file harus berupa object key di folder temp/
	if req.ImageUrl != nil && !strings.HasPrefix(*req.ImageUrl, "temp/") {
		return errors.New("Image url harus berupa object key.")
	}
	if !strings.HasPrefix(req.IdentityDocumentUrl, "temp/") {
		return errors.New("Image url harus berupa object key.")
	}

	if _, err = s.positionRepo.FindOne("id = ?", idPosition); err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Posisi tidak ditemukan atau telah dihapus.")
		}
		helper.Logger("find one position", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if _, err = s.storeRepo.FindOne("id = ?", idStore); err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko tidak ditemukan atau telah dihapus.")
		}
		helper.Logger("find one store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	basicSalary := decimal.NewFromFloat(req.BasicSalary)

	// file yang benar-benar sudah berpindah ke uploads/
	var moved []*string

	txErr := s.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		var imageKey *string
		if req.ImageUrl != nil {
			k := lib.PermanentKey(*req.ImageUrl)
			imageKey = &k
		}
		identityKey := lib.PermanentKey(req.IdentityDocumentUrl)

		newEmployee := entity.Employee{
			ID:                  uuid.New(),
			IdPosition:          idPosition,
			IdStore:             &idStore,
			Name:                req.Name,
			PhoneNumber:         &req.PhoneNumber,
			BasicSalary:         &basicSalary,
			Email:               &req.Email,
			Gender:              &req.Gender,
			DateOfBirth:         &req.DateOfBirth,
			Address:             req.Address,
			Status:              entity.EmployeeStatusActive,
			NationalIDNumber:    &req.NationalIdNumber,
			ImageUrl:            imageKey,
			IdentityDocumentUrl: &identityKey,
			AccountNumber:       &req.AccountNumber,
			BankName:            &req.BankName,
		}

		// 1. insert dulu; kalau bentrok, S3 belum tersentuh
		if err := s.employeeRepo.Create(tx, &newEmployee); err != nil {
			if constraint, ok := helper.UniqueViolationConstraint(err); ok {
				if mapped, found := employeeUniqueErrors[constraint]; found {
					return mapped
				}
				return errEmployeeExists
			}
			return err
		}

		// 2. DB sudah OK, baru pindahkan file
		if req.ImageUrl != nil {
			if _, err := lib.MoveObjectToPermanent(ctx, *req.ImageUrl); err != nil {
				return err // DB rollback otomatis
			}
			moved = append(moved, imageKey)
		}

		if _, err := lib.MoveObjectToPermanent(ctx, req.IdentityDocumentUrl); err != nil {
			return err // DB rollback otomatis
		}
		moved = append(moved, &identityKey)

		return nil
	})

	if txErr != nil {
		// kembalikan hanya file yang sudah sempat pindah
		rollbackFiles(ctx, moved...)

		if errors.Is(txErr, errPhoneTaken) {
			return errPhoneTaken
		}

		if errors.Is(txErr, errEmailTaken) {
			return errEmailTaken
		}

		if errors.Is(txErr, errNationalIDTaken) {
			return errNationalIDTaken
		}

		if errors.Is(txErr, errEmployeeExists) {
			return errEmployeeExists
		}

		helper.Logger("Create employee", filePath, txErr)
		return fmt.Errorf("%s atau mohon upload gambar ulang.", BASE_MESSAGE)
	}

	return nil
}

func (s *employeeService) GetEmployees(req dto.GetEmployeeReq, claims *lib.CustomClaims) (dto.GetEmployeeRes, dto.ResponsePagination, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat karyawan baru."
	_, filePath, _, _ := runtime.Caller(0)

	var page = 1
	var limit = 20
	var orderBy = dto.OrderAsc

	if req.Page != nil {
		page = *req.Page
	}

	if req.Limit != nil {
		limit = *req.Limit
	}

	if req.OrderBy != nil {
		orderBy = *req.OrderBy
	}

	var scopes []func(*gorm.DB) *gorm.DB

	if claims.Role == entity.RoleMitra {
		idMitra := claims.UserId

		staff, err := s.staffRepo.FindOne("id = ?", idMitra)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return dto.GetEmployeeRes{}, dto.ResponsePagination{}, errors.New("Akun tidak ditemukan. Mohon login ulang.")
			}

			helper.Logger("find one staff", filePath, err)
			return dto.GetEmployeeRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
		}

		if staff.IdStore == nil {
			return dto.GetEmployeeRes{}, dto.ResponsePagination{}, errors.New("Akun anda tidak terikat dengan toko. Hubungin admin.")
		}

		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Preload("Store", func(d *gorm.DB) *gorm.DB {
				return d.Where("id = ?", staff.IdStore)
			})
		})
	} else {
		if req.IdStore != nil {
			idStore, err := uuid.Parse(*req.IdStore)
			if err != nil {
				return dto.GetEmployeeRes{}, dto.ResponsePagination{}, errors.New("Id toko tidak valid")
			}

			scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
				return d.Where("id_store = ?", idStore)
			})
		}
	}

	if claims.Role == entity.RoleCustomer {
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Preload("Position", func(d *gorm.DB) *gorm.DB {
				positionName := "%" + "capster" + "%"
				return d.Where("NAME ILIKE ?", positionName)
			})
		})
	} else {
		if req.IdPosition != nil {
			idPosition, err := uuid.Parse(*req.IdPosition)
			if err != nil {
				return dto.GetEmployeeRes{}, dto.ResponsePagination{}, errors.New("Id jabatan tidak valid")
			}

			scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
				return d.Where("id_position = ?", idPosition)
			})
		}
	}

	if req.Query != nil {
		q := "%" + *req.Query + "%"
		scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
			return d.Where("employee.name ILIKE ? OR employee.phone_number = ?", q, q)
		})
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Where("employee.deleted_at IS NULL")
	})

	totalData, err := s.employeeRepo.Count(scopes...)
	if err != nil {
		helper.Logger("Count total employee", filePath, err)
		return dto.GetEmployeeRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	scopes = append(scopes, func(d *gorm.DB) *gorm.DB {
		return d.Clauses(clause.OrderBy{
			Columns: []clause.OrderByColumn{
				{
					Column: clause.Column{Name: "name"},
					Desc:   orderBy == dto.OrderDesc,
				},
			},
		}).Offset((page - 1) * limit).Limit(limit)
	})

	paginationData := helper.GetPaginationData(page, limit, int(totalData))
	employees, err := s.employeeRepo.FindAll(scopes...)
	if err != nil {
		helper.Logger("Find all data employee", filePath, err)
		return dto.GetEmployeeRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	dataEmployees := make([]dto.EmployeeData, 0, len(employees))
	for _, v := range employees {
		var store *dto.StoreEmployee
		if v.IdStore != nil {
			store = &dto.StoreEmployee{
				Id:   *v.IdStore,
				Name: v.Store.Name,
			}
		}

		var imageUrl *string
		if v.ImageUrl != nil {
			pressignedURL, err := lib.GeneratePressignedGetURL(*v.ImageUrl)
			if err != nil {
				helper.Logger("generate presigned image url", filePath, err)
			}

			imageUrl = &pressignedURL
		}

		var identityDocumentURL *string
		if v.IdentityDocumentUrl != nil {
			pressignedURL, err := lib.GeneratePressignedGetURL(*v.IdentityDocumentUrl)
			if err != nil {
				helper.Logger("generate presigned identity doc url", filePath, err)
			}

			identityDocumentURL = &pressignedURL
		}

		dataEmployees = append(dataEmployees, dto.EmployeeData{
			Id:   v.ID,
			Name: v.Name,
			Position: dto.GetPositionRes{
				ID:          v.Position.ID,
				Name:        v.Position.Name,
				BasicSalary: v.Position.BasicSalary,
				CreatedAt:   v.Position.CreatedAt,
			},
			Store:               store,
			PhoneNumber:         v.PhoneNumber,
			Status:              v.Status,
			Gender:              v.Gender,
			Email:               v.Email,
			Address:             v.Address,
			NationalIdNumber:    v.NationalIDNumber,
			ImageUrl:            imageUrl,
			IdentityDocumentUrl: identityDocumentURL,
			AccountNumber:       v.AccountNumber,
			BankName:            v.BankName,
			CreatedAt:           v.CreatedAt,
		})
	}

	totalEmployeeBystatus, err := s.employeeRepo.CountByStatus(func(d *gorm.DB) *gorm.DB {
		return d.Where("deleted_at IS NULL")
	})

	if err != nil {
		helper.Logger("count employee by status", filePath, err)
		return dto.GetEmployeeRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	result := make(map[string]int64, len(totalEmployeeBystatus))
	for _, row := range totalEmployeeBystatus {
		result[row.Status] = row.Total
	}

	active := result[string(entity.EmployeeStatusActive)]
	inactive := result[string(entity.EmployeeStatusInactive)]

	var total int64
	for _, n := range result {
		total += n
	}

	totalStore, err := s.storeRepo.Count()
	if err != nil {
		helper.Logger("count store", filePath, err)
		return dto.GetEmployeeRes{}, dto.ResponsePagination{}, errors.New(BASE_MESSAGE)
	}

	dataKPI := dto.EmployeeKPI{
		TotalEmployees:         total,
		TotalActiveEmployees:   active,
		TotalInactiveEmployees: inactive,
		TotalStores:            totalStore,
	}

	return dto.GetEmployeeRes{
		KPI:       dataKPI,
		Employees: dataEmployees,
	}, paginationData, nil
}

func (s *employeeService) PatchEmployee(ctx context.Context, req dto.PatchEmployeeReq, id string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengubah karyawan."
	_, filePath, _, _ := runtime.Caller(0)

	idEmployee, err := uuid.Parse(id)
	if err != nil {
		return errors.New("Id karyawan tidak valid.")
	}

	updates := make(map[string]interface{})
	if req.Name != nil {
		updates["name"] = req.Name
	}

	if req.PhoneNumber != nil {
		updates["phone_number"] = req.PhoneNumber
	}

	if req.BasicSalary != nil {
		basicSalary := decimal.NewFromFloat(*req.BasicSalary)
		updates["basic_salary"] = basicSalary
	}

	if req.Email != nil {
		updates["email"] = req.Email
	}

	if req.Gender != nil {
		updates["gender"] = req.Gender
	}

	if req.DateOfBirth != nil {
		if !s.validateAgeEmployee(*req.DateOfBirth) {
			return errors.New("Minimum usia adalah 20 tahun & max usia 35 tahun.")
		}

		updates["date_of_birth"] = req.DateOfBirth
	}

	if req.Address != nil {
		updates["address"] = req.Address
	}

	if req.NationalIdNumber != nil {
		if _, err := helper.ValidateIdentityNumber(*req.NationalIdNumber); err != nil {
			return err
		}

		updates["national_id_number"] = req.NationalIdNumber
	}

	employee, err := s.employeeRepo.FindOne("id = ?", idEmployee)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Karyawan tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("find one employee", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	if req.ImageUrl != nil {
		if employee.ImageUrl != nil && strings.Split(*employee.ImageUrl, "/")[0] == "uploads" {
			err = lib.DeleteObject(ctx, *employee.ImageUrl)
			if err != nil {
				helper.Logger("Delete image employee", filePath, err)
				return errors.New(BASE_MESSAGE)
			}
		}

		permanentKey, err := lib.MoveObjectToPermanent(ctx, *req.ImageUrl)
		if err != nil {
			return err
		}

		updates["image_url"] = permanentKey
	}

	if req.IdentityDocumentUrl != nil {
		if employee.IdentityDocumentUrl != nil && strings.Split(*employee.IdentityDocumentUrl, "/")[0] == "uploads" {
			err = lib.DeleteObject(ctx, *employee.IdentityDocumentUrl)
			if err != nil {
				helper.Logger("Delete identity doc employee", filePath, err)
				return errors.New(BASE_MESSAGE)
			}
		}

		permanentKey, err := lib.MoveObjectToPermanent(ctx, *req.IdentityDocumentUrl)
		if err != nil {
			return err
		}

		updates["identity_document_url"] = permanentKey
	}

	if req.IdPosition != nil {
		idPosition, err := uuid.Parse(*req.IdPosition)
		if err != nil {
			return errors.New("Id jabatan tidak valid.")
		}

		_, err = s.positionRepo.FindOne("id = ?", idPosition)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return errors.New("Posisi tidak ditemukan atau telah dihapus.")
			}

			helper.Logger("find one position", filePath, err)
			return errors.New(BASE_MESSAGE)
		}

		updates["id_position"] = req.IdPosition
	}

	if req.IdStore != nil {
		idStore, err := uuid.Parse(*req.IdStore)
		if err != nil {
			return errors.New("Id toko tidak valid.")
		}

		_, err = s.storeRepo.FindOne("id = ?", idStore)
		if err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return errors.New("Toko tidak ditemukan atau telah dihapus.")
			}

			helper.Logger("find one store", filePath, err)
			return errors.New(BASE_MESSAGE)
		}

		updates["id_store"] = req.IdStore
	}

	if req.AccountNumber != nil {
		if ok := s.isValidAccountNumber(*req.AccountNumber); !ok {
			return errors.New("Periksa no rekening yang benar.")
		}

		updates["account_number"] = req.AccountNumber
	}

	if req.BankName != nil {
		updates["bank_name"] = req.BankName
	}

	if req.Status != nil {
		updates["status"] = req.Status
	}

	var errEmployeeNotFound = errors.New("Karyawan tidak ditemukan")
	err = s.db.Transaction(func(tx *gorm.DB) error {
		rowsAffected, err := s.employeeRepo.Updates(tx, updates, func(d *gorm.DB) *gorm.DB {
			return d.Where("id = ?", idEmployee)
		})

		if err != nil {
			if constraint, ok := helper.UniqueViolationConstraint(err); ok {
				if mapped, found := employeeUniqueErrors[constraint]; found {
					return mapped
				}
				return errEmployeeExists
			}
			return err
		}

		if rowsAffected == 0 {
			return errEmployeeNotFound
		}

		return nil
	})

	if err != nil {
		if errors.Is(err, errEmployeeNotFound) {
			return errors.New("Data karyawan tidak ditemukan atau telah dihapus.")
		}

		if errors.Is(err, errEmailTaken) {
			return err
		}

		if errors.Is(err, errPhoneTaken) {
			return err
		}

		if errors.Is(err, errNationalIDTaken) {
			return err
		}

		if errors.Is(err, errEmployeeExists) {
			return err
		}

		helper.Logger("Update employee", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *employeeService) SoftDeleteEmployee(id string) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat menghapus karyawan."
	_, filePath, _, _ := runtime.Caller(0)

	idEmployee, err := uuid.Parse(id)
	if err != nil {
		return errors.New("Id karyawan tidak valid")
	}

	var errEmployeeNotFound = errors.New("Karyawan tidak ditemukan")
	err = s.db.Transaction(func(tx *gorm.DB) error {
		rowsAffected, err := s.employeeRepo.SoftDelete(tx, idEmployee)
		if err != nil {
			return err
		}

		if rowsAffected == 0 {
			return errEmployeeNotFound
		}

		return nil
	})

	if err != nil {
		if errors.Is(err, errEmployeeNotFound) {
			return errors.New("Karyawan tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("delete employee", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *employeeService) Absent(req dto.CreateAbsentReq) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengabsen karyawan."
	_, filePath, _, _ := runtime.Caller(0)

	idEmployee, err := uuid.Parse(req.IdEmployee)
	if err != nil {
		return errors.New("Id karyawan tidak valid.")
	}

	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return errors.New("Id toko tidak valid.")
	}

	_, err = s.employeeRepo.FindOne("id = ?", idEmployee)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Karyawan tidak ditemukan atau telah dihapus")
		}

		helper.Logger("find one employee", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko tidak ditemukan atau telah dihapus")
		}

		helper.Logger("find one store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	loc, err := time.LoadLocation(string(dataStore.Timezone))
	if err != nil {
		helper.Logger("load location", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	now := time.Now().In(loc)
	startOfDay := time.Date(
		now.Year(),
		now.Month(),
		now.Day(),
		0, 0, 0, 0, loc,
	)
	startOfNextDay := startOfDay.AddDate(0, 0, 1)

	_, err = s.
		absentRepo.
		FindOne("id_employee = ? AND created_at >= ? AND created_at < ?", idEmployee, startOfDay, startOfNextDay)

	if err == nil {
		return errors.New("Karyawan telah absen.")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("find absent employee", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	absent := entity.Absent{
		ID:         uuid.New(),
		IdEmployee: idEmployee,
		IdStore:    idStore,
	}

	err = s.absentRepo.Create(&absent)
	if err != nil {
		if helper.IsUniqueViolation(err) {
			return errors.New("Karyawan ini telah absen.")
		}

		helper.Logger("Create absent", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *employeeService) GetEmployeeAbsent(req dto.GetEmployeeAbsentReq) ([]dto.GetEmployeeAbsentRes, error) {
	const BASE_MESSAGE = "Terjadi kesalahan saat mengabsen karyawan."
	_, filePath, _, _ := runtime.Caller(0)

	idStore, err := uuid.Parse(req.IdStore)
	if err != nil {
		return []dto.GetEmployeeAbsentRes{}, errors.New("Id toko tidak valid.")
	}

	dataStore, err := s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return []dto.GetEmployeeAbsentRes{}, errors.New("Toko tidak ditemukan")
		}

		helper.Logger("find one store", filePath, err)
		return []dto.GetEmployeeAbsentRes{}, errors.New(BASE_MESSAGE)
	}

	loc, err := time.LoadLocation(string(dataStore.Timezone))
	if err != nil {
		helper.Logger("load location", filePath, err)
		return []dto.GetEmployeeAbsentRes{}, errors.New(BASE_MESSAGE)
	}

	now := time.Now().In(loc)
	startOfDay := time.Date(
		now.Year(),
		now.Month(),
		now.Day(),
		0, 0, 0, 0, loc,
	)
	startOfNextDay := startOfDay.AddDate(0, 0, 1)

	rows, err := s.employeeRepo.FindWithPresence(idStore, startOfDay, startOfNextDay)
	if err != nil {
		helper.Logger("find employee with presence", filePath, err)
		return nil, errors.New(BASE_MESSAGE)
	}

	res := make([]dto.GetEmployeeAbsentRes, 0, len(rows))
	for _, v := range rows {
		res = append(res, dto.GetEmployeeAbsentRes{
			Id:           v.ID,
			Name:         v.Name,
			ImageUrl:     v.ImageUrl,
			Status:       v.Status,
			PositionName: v.PositionName,
			IsPresent:    v.IsPresent,
		})
	}

	return res, nil
}
