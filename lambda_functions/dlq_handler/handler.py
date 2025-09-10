import os
import json
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

MAIN_QUEUE_URL = os.getenv("MAIN_QUEUE_URL")

sqs = boto3.client("sqs")

def lambda_handler(event, context):
    """
    Lambda triggered by SQS DLQ messages
    """
    for record in event.get("Records", []):
        try:
            message_id = record["messageId"]
            body = record["body"]
            logger.warning(f"DLQ Message received: ID={message_id}, Body={body}")

            # Optionally replay message to main queue
            if MAIN_QUEUE_URL:
                response = sqs.send_message(QueueUrl=MAIN_QUEUE_URL, MessageBody=body)
                logger.info(f"Replayed DLQ message {message_id} to main queue: {response.get('MessageId')}")
        except Exception as e:
            logger.error(f"Failed processing DLQ message: {e}")
    return {"status": "processed", "records": len(event.get("Records", []))}
