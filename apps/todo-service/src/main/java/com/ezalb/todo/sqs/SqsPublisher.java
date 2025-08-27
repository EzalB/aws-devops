package com.example.todo.sqs;

import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;

@Component
public class SqsPublisher {

    private final SqsClient sqsClient;
    private final String queueUrl;

    public SqsPublisher() {
        this.sqsClient = SqsClient.create();
        this.queueUrl = System.getenv("SQS_QUEUE_URL");
    }

    public void publishNotification(String userId, String message) {
        String payload = String.format("{\"userId\": \"%s\", \"message\": \"%s\"}", userId, message);

        SendMessageRequest sendMsgRequest = SendMessageRequest.builder()
                .queueUrl(queueUrl)
                .messageBody(payload)
                .build();

        sqsClient.sendMessage(sendMsgRequest);
        System.out.println("Published to SQS: " + payload);
    }
}
