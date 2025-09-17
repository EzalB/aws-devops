package httpserver

import (
	"encoding/json"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/EzalB/aws-devops/apps/notifier-service/internal/config"
	"github.com/EzalB/aws-devops/apps/notifier-service/internal/logging"
	"github.com/EzalB/aws-devops/apps/notifier-service/internal/metrics"
	"github.com/EzalB/aws-devops/apps/notifier-service/internal/notify"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

type notifyReq struct {
	To      string `json:"to"`
	Subject string `json:"subject"`
	Body    string `json:"body"`
}

func NewRouter(cfg config.Config, log *logging.Logger, reg *prometheus.Registry, tp interface{}, sender *notify.Sender) http.Handler {
	r := chi.NewRouter()
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Recoverer)

	// Health
	r.Get("/healthz", func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusOK) })
	r.Get("/readyz", func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusOK) })

	// Metrics
	r.Method(http.MethodGet, cfg.MetricsPath, metrics.HandlerFor(reg))

	// Notify endpoint (instrumented)
	r.Method(http.MethodPost, "/notify", otelhttp.NewHandler(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req notifyReq
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		ctx := r.Context()
		if err := sender.Send(ctx, "http", notify.Message{To: req.To, Subject: req.Subject, Body: req.Body}); err != nil {
			log.Errorw("send failed", "error", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
// 		w.WriteHeader(http.StatusAccepted)
		w.Write([]byte("queued"))
	}), "notify"))

	return r
}