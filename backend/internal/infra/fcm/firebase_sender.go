package fcm

import (
	"context"
	"errors"
	"fmt"
	"time"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"google.golang.org/api/option"
)

type firebaseSender struct {
	client *messaging.Client
}

var (
	ErrCredential = errors.New("Credential service account beluum diisi")
)

func NewFirebaseSender(ctx context.Context, credJSON []byte, credFile string) (Sender, error) {
	var opt option.ClientOption
	switch {
	case len(credJSON) > 0:
		opt = option.WithAuthCredentialsJSON(option.CredentialsType(credJSON), credJSON)
	case credFile != "":
		opt = option.WithAuthCredentialsFile(option.CredentialsType(credFile), credFile)
	default:
		return nil, ErrCredential
	}

	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		return nil, fmt.Errorf("fcm: init app: %w", err)
	}

	client, err := app.Messaging(ctx)
	if err != nil {
		return nil, fmt.Errorf("fcm: init messaging: %w", err)
	}

	return &firebaseSender{client: client}, nil
}

func (s *firebaseSender) Send(ctx context.Context, m Message) (string, error) {
	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	id, err := s.client.Send(ctx, &messaging.Message{
		Fid: m.Token,
		Notification: &messaging.Notification{
			Title: m.Title,
			Body:  m.Body,
		},
		Data: m.Data,
		Android: &messaging.AndroidConfig{
			Priority: "high",
		},
	})

	if err != nil {
		return "", classify(err)
	}

	return id, nil
}

func classify(err error) error {
	switch {
	case messaging.IsUnregistered(err), messaging.IsSenderIDMismatch(err):
		return fmt.Errorf("%w: %v", ErrInvalidToken, err)
	case messaging.IsUnavailable(err),
		messaging.IsInternal(err),
		messaging.IsQuotaExceeded(err),
		errors.Is(err, context.DeadlineExceeded),
		errors.Is(err, context.Canceled):
		return fmt.Errorf("%w: %v", ErrTemorary, err)
	default:
		return fmt.Errorf("%w: %v", ErrPermanent, err)
	}
}
