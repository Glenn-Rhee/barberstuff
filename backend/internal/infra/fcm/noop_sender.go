package fcm

import (
	"context"
	"log"

	"github.com/google/uuid"
)

type noopSender struct{}

func NewNoopSender() Sender {
	return &noopSender{}
}
func (noopSender) Send(_ context.Context, m Message) (string, error) {
	log.Printf("[fcm-noop] title=%q body=%q", m.Title, m.Body) // token sengaja tidak dicatat
	return "noop-" + uuid.NewString(), nil
}
