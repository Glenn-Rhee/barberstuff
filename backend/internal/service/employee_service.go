package service

import (
	"barberstuff_backend/internal/dto"
	"barberstuff_backend/internal/entity"
	"barberstuff_backend/internal/helper"
	"barberstuff_backend/internal/lib"
	"barberstuff_backend/internal/repository"
	"context"
	"errors"
	"log"
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
	GetEmployees(req dto.GetEmployeeReq) (dto.GetEmployeeRes, dto.ResponsePagination, error)
	PatchEmployee(ctx context.Context, req dto.PatchEmployeeReq, id string) error
	SoftDeleteEmployee(id string) error
	Absent(req dto.CreateAbsentReq) error
}

type employeeService struct {
	employeeRepo repository.EmployeeRepository
	positionRepo repository.PositionRepository
	storeRepo    repository.StoreRepository
	absentRepo   repository.AbsentRepository
	db           *gorm.DB
}

func NewEmployeeService(
	er repository.EmployeeRepository,
	pr repository.PositionRepository,
	sr repository.StoreRepository,
	ar repository.AbsentRepository,
	d *gorm.DB,
) EmployeeService {
	return &employeeService{
		employeeRepo: er,
		positionRepo: pr,
		storeRepo:    sr,
		absentRepo:   ar,
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
	"email_employee_unique":              errPhoneTaken,
	"employee_phone_number_unique":       errEmailTaken,
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

func (s *employeeService) CreateEmployee(ctx context.Context, req dto.CreateEmployeeReq) error {
	const BASE_MESSAGE = "Terjadi kesalahan saat membuat karyawan baru."
	_, filePath, _, _ := runtime.Caller(0)

	if !s.validateAgeEmployee(req.DateOfBirth) {
		return errors.New("Minimum usia adalah 20 tahun & max usia 35 tahun.")
	}

	if _, err := helper.ValidateIdentityNumber(req.NationalIdNumber); err != nil {
		return err
	}

	if ok := s.isValidAccountNumber(req.AccountNumber); !ok {
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

	_, err = s.positionRepo.FindOne("id = ?", idPosition)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Posisi tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("find one position", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	_, err = s.storeRepo.FindOne("id = ?", idStore)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("Toko tidak ditemukan atau telah dihapus.")
		}

		helper.Logger("find one store", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	var imageUrl *string
	if req.ImageUrl != nil {
		permanentKey, err := lib.MoveObjectToPermanent(ctx, *req.ImageUrl)
		if err != nil {
			return err
		}

		imageUrl = &permanentKey
	}

	identityKeyUrl, err := lib.MoveObjectToPermanent(ctx, req.IdentityDocumentUrl)
	if err != nil {
		log.Println("Cihuy")
		return err
	}

	basicSalary := decimal.NewFromFloat(req.BasicSalary)

	err = s.db.Transaction(func(tx *gorm.DB) error {
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
			ImageUrl:            imageUrl,
			IdentityDocumentUrl: &identityKeyUrl,
			AccountNumber:       &req.AccountNumber,
			BankName:            &req.BankName,
		}

		err = s.employeeRepo.Create(tx, &newEmployee)
		if err != nil {
			if constraint, ok := helper.UniqueViolationConstraint(err); ok {
				if mapped, found := employeeUniqueErrors[constraint]; found {
					return mapped
				}
				return errEmployeeExists
			}
			return err
		}

		return nil
	})

	if err != nil {
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

		helper.Logger("Create employee", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	return nil
}

func (s *employeeService) GetEmployees(req dto.GetEmployeeReq) (dto.GetEmployeeRes, dto.ResponsePagination, error) {
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
		return errors.New("Karyawan telah absent.")
	}

	if !errors.Is(err, gorm.ErrRecordNotFound) {
		helper.Logger("find absent employee", filePath, err)
		return errors.New(BASE_MESSAGE)
	}

	 absent := entity.Absent{
		ID: uuid.New(),
		IdEmployee: idEmployee,
		IdStore: idStore,
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
