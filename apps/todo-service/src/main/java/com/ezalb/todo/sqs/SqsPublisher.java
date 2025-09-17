package com.ezalb.todo.sqs;

import com.ezalb.todo.config.SqsProperties;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.SqsClientBuilder;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;

import java.net.URI;

@Component
public class SqsPublisher {

    private final SqsClient sqsClient;
    private final String queueUrl;

    public SqsPublisher(SqsProperties properties) {
        final String endpoint = properties.getEndpoint();

        SqsClientBuilder builder = SqsClient.builder()
                .region(Region.of(properties.getRegion()));

        if (endpoint != null && !endpoint.isBlank()) {
            builder.endpointOverride(URI.create(endpoint));
        }

        this.sqsClient = builder.build();
        this.queueUrl = properties.getQueueUrl();
    }

    public void publishNotification(String userId, String message) {
        String payload = String.format(
                "{\"to\": \"%s\", \"subject\": \"Todo Events\", \"body\": \"%s\"}",
                userId, message
        );

        SendMessageRequest sendMsgRequest = SendMessageRequest.builder()
                .queueUrl(queueUrl)
                .messageBody(payload)
                .build();

        sqsClient.sendMessage(sendMsgRequest);
        System.out.println("Published to SQS: " + payload);
    }
}
