package notify

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/EzalB/aws-devops/apps/notifier-service/internal/logging"
	"github.com/EzalB/aws-devops/apps/notifier-service/internal/metrics"
)

type Sender struct {
	log *logging.Logger
}

type Message struct {
	To      string `json:"to"`
	Subject string `json:"subject"`
	Body    string `json:"body"`
}

func New(l *logging.Logger, reg interface{}) *Sender { // reg kept for symmetry
	return &Sender{log: l}
}

func (s *Sender) Send(ctx context.Context, channel string, msg Message) error {
	// Simulate a delivery latency
	select {
	case <-time.After(10 * time.Millisecond):
	case <-ctx.Done():
		metrics.NotificationsTotal.WithLabelValues(channel, "cancel").Inc()
		return ctx.Err()
	}

	b, _ := json.Marshal(msg)
	s.log.Infow("notification sent", "channel", channel, "payload", string(b))
	metrics.NotificationsTotal.WithLabelValues(channel, "success").Inc()
	return nil
}

func (s *Sender) SendString(ctx context.Context, channel, payload string) error {
	m := Message{To: "demo@example.com", Subject: fmt.Sprintf("via-%s", channel), Body: payload}
	return s.Send(ctx, channel, m)
}