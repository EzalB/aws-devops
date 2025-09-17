package sqsconsumer

import (
	"context"
	"encoding/json"
	"errors"
	"strings"
	"time"

	awsconfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/aws/aws-sdk-go-v2/service/sqs/types"
	"github.com/EzalB/aws-devops/apps/notifier-service/internal/config"
	"github.com/EzalB/aws-devops/apps/notifier-service/internal/logging"
	"github.com/EzalB/aws-devops/apps/notifier-service/internal/notify"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/trace"
)

type sqsCarrier map[string]string

func (c sqsCarrier) Get(key string) string          { return c[key] }
func (c sqsCarrier) Set(key, val string)            { c[key] = val }
func (c sqsCarrier) Keys() []string                 { ks := make([]string,0,len(c)); for k := range c { ks = append(ks,k) }; return ks }

func MaybeStart(cfg config.Config, log *logging.Logger, tp trace.TracerProvider, sender *notify.Sender) (*sqs.Client, context.CancelFunc, error) {
	if strings.TrimSpace(cfg.SQSQueueURL) == "" {
		return nil, func(){}, nil
	}
	ctx, cancel := context.WithCancel(context.Background())
	// AWS config picks up env/IRSA automatically
	awscfg, err := awsconfig.LoadDefaultConfig(
        ctx,
        awsconfig.WithRegion(cfg.AWSRegion),
        awsconfig.WithEndpointResolverWithOptions(
            aws.EndpointResolverWithOptionsFunc(
                func(service, region string, options ...interface{}) (aws.Endpoint, error) {
                    if strings.Contains(cfg.SQSQueueURL, "localhost") {
                        return aws.Endpoint{
                            URL:           "http://localhost:4566",
                            SigningRegion: cfg.AWSRegion,
                        }, nil
                    }
                    return aws.Endpoint{}, &aws.EndpointNotFoundError{}
                }),
        ),
    )

// 	awscfg, err := awsconfig.LoadDefaultConfig(ctx, awsconfig.WithRegion(cfg.AWSRegion))
	if err != nil {
		cancel()
		return nil, nil, err
	}
	client := sqs.NewFromConfig(awscfg)
	go poll(ctx, client, cfg.SQSQueueURL, log, sender)
	return client, cancel, nil
}

func poll(ctx context.Context, client *sqs.Client, queueURL string, log *logging.Logger, sender *notify.Sender) {
	tracer := otel.Tracer("notifier/sqs")
	for {
		select {
		case <-ctx.Done():
			log.Infow("sqs poller stopped")
			return
		default:
		}

		out, err := client.ReceiveMessage(ctx, &sqs.ReceiveMessageInput{
			QueueUrl:            &queueURL,
			MaxNumberOfMessages: 5,
			WaitTimeSeconds:     20,
			VisibilityTimeout:   30,
			MessageAttributeNames: []string{"All"},
		})
		if err != nil {
			// Backoff on error
			log.Errorw("sqs receive error", "error", err)
			select { case <-time.After(2 * time.Second): case <-ctx.Done(): return }
			continue
		}

		for _, m := range out.Messages {
			// Extract trace context from message attributes if present
			carrier := sqsCarrier{}
			for k, v := range m.MessageAttributes {
				if v.StringValue != nil { carrier[strings.ToLower(k)] = *v.StringValue }
			}
			parent := otel.GetTextMapPropagator().Extract(ctx, carrier)

			func() {
				ctx, span := tracer.Start(parent, "sqs.process", trace.WithAttributes(
					attribute.String("sqs.message_id", *m.MessageId),
					attribute.Int("sqs.len", len(*m.Body)),
				))
				defer span.End()

				var msg notify.Message
				if err := json.Unmarshal([]byte(*m.Body), &msg); err != nil {
					span.RecordError(err)
					log.Errorw("bad message body", "error", err)
					_ = deleteMessage(ctx, client, queueURL, m)
					return
				}
				if err := sender.Send(ctx, "sqs", msg); err != nil {
					span.RecordError(err)
					log.Errorw("send failed", "error", err)
					return
				}
				if err := deleteMessage(ctx, client, queueURL, m); err != nil {
					span.RecordError(err)
					log.Errorw("delete failed", "error", err)
				}
			}()
		}
	}
}

func deleteMessage(ctx context.Context, client *sqs.Client, queueURL string, m types.Message) error {
	if m.ReceiptHandle == nil { return errors.New("missing receipt handle") }
	_, err := client.DeleteMessage(ctx, &sqs.DeleteMessageInput{
		QueueUrl:      &queueURL,
		ReceiptHandle: m.ReceiptHandle,
	})
	return err
}