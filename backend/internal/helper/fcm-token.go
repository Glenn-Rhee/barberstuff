package helper

import (
	"errors"
	"regexp"
	"strings"
)

var fcmTokenRe = regexp.MustCompile(`^[A-Za-z0-9:_\-]+$`)

func ValidateFCMToken(t string) error {
	t = strings.TrimSpace(t)
	if len(t) < 100 || len(t) > 4096 {
		return errors.New("fcm_token length invalid")
	}
	if !fcmTokenRe.MatchString(t) {
		return errors.New("fcm_token format invalid")
	}
	return nil
}
