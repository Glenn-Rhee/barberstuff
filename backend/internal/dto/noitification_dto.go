package dto

import "github.com/google/uuid"

type NotifyInput struct {
	IdUser     uuid.UUID
	EventType  string
	Title      string
	Body       string
	Data       map[string]string
	DedupKey   string
	IdCampaign *uuid.UUID
}

type NotifyResult struct {
	Created    bool
	ID         uuid.UUID
	Deliveries int
}
