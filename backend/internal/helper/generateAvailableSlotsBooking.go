package helper

import "time"

func GenerateAvailableSlots(bookingDate time.Time, openHour, closeHour time.Time) []time.Time {
	loc := bookingDate.Location()

	start := time.Date(
		bookingDate.Year(), bookingDate.Month(), bookingDate.Day(),
		openHour.Hour(), openHour.Minute(), 0, 0, loc,
	)
	end := time.Date(
		bookingDate.Year(), bookingDate.Month(), bookingDate.Day(),
		closeHour.Hour(), closeHour.Minute(), 0, 0, loc,
	)

	var slots []time.Time
	for t := start; t.Before(end); t = t.Add(30 * time.Minute) {
		slots = append(slots, t)
	}

	return slots
}
