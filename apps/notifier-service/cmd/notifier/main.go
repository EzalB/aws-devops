package main

import (
	"context"
	"errors"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/yourorg/notifier-service/internal/config"
	"github.com/yourorg/notifier-service/internal/httpserver"
	"github.com/yourorg/notifier-service/internal/logging"
	"github.com/yourorg/notifier-service/internal/metrics"
	"github.com/yourorg/notifier-service/internal/notify"
	"github.com/yourorg/notifier-service/internal/sqsconsumer"
	"github.com/yourorg/notifier-service/internal/tracing"
	"github.com/yourorg/notifier-service/internal/version"
)

func main() {
	cfg := config.Load()
	logger := logging.New(cfg.LogLevel)
	logger.Infow("starting notifier-service", "version", version.Version, "env", cfg.Env)

	// OpenTelemetry setup
	tp, shutdownTracer, err := tracing.InitProvider(cfg)
	if err != nil {
	}
	defer shutdownTracer(context.Background())

	// Prometheus metrics registry
	reg := metrics.MustSetupRegistry()

	// Notifier (simulated email/log)
	n := notify.New(logger, reg)

	// HTTP server (ingest + health + metrics)
	r := httpserver.NewRouter(cfg, logger, reg, tp, n)
	srv := &http.Server{Addr: ":" + cfg.Port, Handler: r}

	// SQS consumer (optional)
	consumer, consCancel, err := sqsconsumer.MaybeStart(cfg, logger, tp, n)
	if err != nil {
		logger.Fatalw("failed to start sqs consumer", "error", err)
	}
	defer consCancel()
	if consumer != nil {
		logger.Infow("sqs consumer running", "queue", cfg.SQSQueueURL)
	}

	// Start HTTP server

go func() {
		logger.Infow("http server listening", "addr", srv.Addr)
		if err := srv.ListenAndServe(); !errors.Is(err, http.ErrServerClosed) {
			logger.Fatalw("http server error", "error", err)
		}
	}()

	// Wait for termination
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)
	<-sigCh
	logger.Infow("shutdown signal received")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		logger.Errorw("http shutdown error", "error", err)
	}
	logger.Infow("server stopped")
}