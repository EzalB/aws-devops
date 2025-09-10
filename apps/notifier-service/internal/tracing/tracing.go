package tracing

import (
	"context"
	"time"

	"github.com/EzalB/notifier-service/internal/config"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	"go.opentelemetry.io/otel/sdk/trace"
	semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
)

func InitProvider(cfg config.Config) (*trace.TracerProvider, func(context.Context) error, error) {
	exp, err := otlptracehttp.New(context.Background(), otlptracehttp.WithEndpointURL(cfg.OTLPEndpoint))
	if err != nil {
		return nil, nil, err
	}

	res, err := resource.New(context.Background(),
		resource.WithAttributes(
			semconv.ServiceName(cfg.ServiceName),
			semconv.ServiceVersion(cfg.ServiceVersion),
			semconv.DeploymentEnvironment(cfg.Env),
		),
	)
	if err != nil {
		return nil, nil, err
	}

	tp := trace.NewTracerProvider(
		trace.WithBatcher(exp, trace.WithMaxExportBatchSize(512), trace.WithBatchTimeout(2*time.Second)),
		trace.WithResource(res),
	)
	otel.SetTracerProvider(tp)
	otel.SetTextMapPropagator(propagation.TraceContext{})
	return tp, tp.Shutdown, nil
}