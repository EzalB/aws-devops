package config

import (
	"os"
)

type Config struct {
	Port          string
	Env           string
	LogLevel      string
	MetricsPath   string
	OTLPEndpoint  string
	ServiceName   string
	ServiceVersion string
	SQSQueueURL   string
	AWSRegion     string
}

func getenv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func Load() Config {
	return Config{
		Port:           getenv("PORT", "8081"),
		Env:            getenv("ENV", "dev"),
		LogLevel:       getenv("LOG_LEVEL", "info"),
		MetricsPath:    getenv("PROMETHEUS_METRICS_PATH", "/metrics"),
		OTLPEndpoint:   getenv("OTEL_EXPORTER_OTLP_ENDPOINT", ""),
		ServiceName:    getenv("OTEL_SERVICE_NAME", "notifier-service"),
		ServiceVersion: getenv("OTEL_SERVICE_VERSION", "0.1.0"),
		SQSQueueURL:    getenv("SQS_QUEUE_URL", "http://localhost:4566/000000000000/todo-events"),
		AWSRegion:      getenv("AWS_REGION", "us-east-1"),
	}
}