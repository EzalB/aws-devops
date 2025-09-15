package com.ezalb.todo.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "aws.sqs")
public class SqsProperties {
    private String queueUrl;
    private String region;
    private String endpoint;
}
