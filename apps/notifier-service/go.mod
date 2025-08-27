module github.com/yourorg/notifier-service

go 1.21

require (
    github.com/aws/aws-sdk-go-v2 v1.30.1
    github.com/aws/aws-sdk-go-v2/config v1.27.23
    github.com/aws/aws-sdk-go-v2/service/sqs v1.33.2
    github.com/go-chi/chi/v5 v5.0.12
    github.com/prometheus/client_golang v1.18.0
    go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp v0.54.0
    go.opentelemetry.io/otel v1.28.0
    go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp v1.28.0
    go.opentelemetry.io/otel/sdk v1.28.0
    go.opentelemetry.io/otel/trace v1.28.0
)