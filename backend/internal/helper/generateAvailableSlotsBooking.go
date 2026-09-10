package helper

import "time"

func GenerateAvailableSlots(bookingDate, openHour, closeHour time.Time, loc *time.Location) []time.Time { // FIX: tambah parameter loc
	bookingDateLocal := bookingDate.In(loc) // FIX: convert ke lokasi toko dulu

	start := time.Date(
		bookingDateLocal.Year(), bookingDateLocal.Month(), bookingDateLocal.Day(), // FIX: pakai bookingDateLocal
		openHour.Hour(), openHour.Minute(), 0, 0, loc,
	)
	end := time.Date(
		bookingDateLocal.Year(), bookingDateLocal.Month(), bookingDateLocal.Day(), // FIX: pakai bookingDateLocal
		closeHour.Hour(), closeHour.Minute(), 0, 0, loc,
	)

	var slots []time.Time
	for t := start; t.Before(end); t = t.Add(30 * time.Minute) {
		slots = append(slots, t)
	}

	return slots
}