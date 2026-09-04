package helper

import (
	"fmt"
	"regexp"
	"time"

	"github.com/go-playground/validator/v10"
)

func FormatValidationError(err error) []string {
	var errors []string

	validationErrors, ok := err.(validator.ValidationErrors)
	if !ok {
		// error bukan dari validator (misal JSON malformed)
		return []string{"Format data tidak valid"}
	}

	for _, fe := range validationErrors {
		errors = append(errors, formatFieldError(fe))
	}

	return errors
}

func formatFieldError(fe validator.FieldError) string {
	field := fe.Field()

	switch fe.Tag() {
	case "required":
		return fmt.Sprintf("%s wajib diisi", field)
	case "email":
		return fmt.Sprintf("%s harus berupa email yang valid", field)
	case "numeric":
		return fmt.Sprintf("%s harus berupa angka", field)
	case "min":
		return fmt.Sprintf("%s minimal %s karakter", field, fe.Param())
	case "max":
		return fmt.Sprintf("%s maksimal %s karakter", field, fe.Param())
	case "gt":
		return fmt.Sprintf("%s harus lebih dari %s karakter", field, fe.Param())
	default:
		return fmt.Sprintf("%s tidak valid", field)
	}
}

func ValidatePhoneNumber(phoneNumber string) bool {
	var phoneRegex = regexp.MustCompile(`^(\+62|62|0)8[1-9][0-9]{6,10}$`)
	return phoneRegex.MatchString(phoneNumber)
}

func ValidateOTP(otp string) bool {
	var otpRegex = regexp.MustCompile(`^\d{6}$`)
	return otpRegex.MatchString(otp)
}

func ValidateMinAge(dateOfBirth time.Time) bool {
	minBirthDate := time.Now().AddDate(0, -6, 0)

	return !dateOfBirth.After(minBirthDate)
}
