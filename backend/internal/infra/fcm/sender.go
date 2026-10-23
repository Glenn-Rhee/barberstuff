package fcm

import (
	"context"
	"errors"
)

var (
	ErrInvalidToken = errors.New("invalid token")
	ErrTemorary = errors.New("Temporary Error")
	ErrPermanent = errors.New("Permanent Error")
)

type Message struct {
	Token string
	Title string
	Body string
	Data map[string]string
}

type Sender interface {
	Send(ctx context.Context, m Message) (string, error)
}