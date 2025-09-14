module github.com/EzalB/notifier-service

go 1.22

require (
	github.com/aws/aws-sdk-go-v2/config v1.29.17
	github.com/aws/aws-sdk-go-v2/service/sqs v1.38.8
	github.com/go-chi/chi/v5 v5.0.12
	github.com/prometheus/client_golang v1.18.0
	go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp v0.54.0
	go.opentelemetry.io/otel v1.29.0
	go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp v1.28.0
	go.opentelemetry.io/otel/sdk v1.28.0
	go.opentelemetry.io/otel/trace v1.29.0
)

require (
	github.com/aws/aws-sdk-go-v2 v1.39.0
	github.com/aws/aws-sdk-go-v2/credentials v1.17.70
	github.com/aws/aws-sdk-go-v2/feature/ec2/imds v1.16.32
	github.com/aws/aws-sdk-go-v2/internal/configsources v1.3.36
	github.com/aws/aws-sdk-go-v2/internal/endpoints/v2 v2.6.36
	github.com/aws/aws-sdk-go-v2/internal/ini v1.8.3
	github.com/aws/aws-sdk-go-v2/service/internal/accept-encoding v1.12.4
	github.com/aws/aws-sdk-go-v2/service/internal/presigned-url v1.12.17
	github.com/aws/aws-sdk-go-v2/service/sso v1.25.5
	github.com/aws/aws-sdk-go-v2/service/ssooidc v1.30.3
	github.com/aws/aws-sdk-go-v2/service/sts v1.34.0
	github.com/aws/smithy-go v1.23.0
	github.com/beorn7/perks v1.0.1
	github.com/cenkalti/backoff/v4 v4.3.0
	github.com/cespare/xxhash/v2 v2.2.0
	github.com/felixge/httpsnoop v1.0.4
	github.com/go-logr/logr v1.4.2
	github.com/go-logr/stdr v1.2.2
	github.com/google/uuid v1.6.0
	github.com/grpc-ecosystem/grpc-gateway/v2 v2.20.0
	github.com/matttproud/golang_protobuf_extensions/v2 v2.0.0
	github.com/prometheus/client_model v0.5.0
	github.com/prometheus/common v0.45.0
	github.com/prometheus/procfs v0.12.0
	go.opentelemetry.io/otel/exporters/otlp/otlptrace v1.28.0
	go.opentelemetry.io/otel/metric v1.29.0
	go.opentelemetry.io/proto/otlp v1.3.1
	golang.org/x/net v0.26.0
	golang.org/x/sys v0.21.0
	golang.org/x/text v0.16.0
	google.golang.org/genproto/googleapis/api v0.0.0-20240701130421-f6361c86f094
	google.golang.org/genproto/googleapis/rpc v0.0.0-20240701130421-f6361c86f094
	google.golang.org/grpc v1.64.0
	google.golang.org/protobuf v1.34.2
)
