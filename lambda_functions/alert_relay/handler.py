import os
import json
import logging
import urllib.request

logger = logging.getLogger()
logger.setLevel(logging.INFO)

SLACK_WEBHOOK_URL = os.getenv("SLACK_WEBHOOK_URL")

def lambda_handler(event, context):
    """
    Lambda triggered by Alertmanager webhook (API Gateway POST request)
    """
    try:
        # API Gateway may wrap body in event['body']
        body = event.get("body")
        if isinstance(body, str):
            body = json.loads(body)

        alerts = body.get("alerts", [])
        for alert in alerts:
            status = alert.get("status")
            labels = alert.get("labels", {})
            annotations = alert.get("annotations", {})
            alert_name = labels.get("alertname", "Unknown")
            description = annotations.get("description", "")
            message = f"*Alert:* {alert_name}\n*Status:* {status}\n*Description:* {description}\n*Labels:* {labels}"

            logger.info(f"Forwarding alert to Slack: {message}")
            post_to_slack(message)

        return {"statusCode": 200, "body": json.dumps({"message": "Alerts processed"})}
    except Exception as e:
        logger.error(f"Error processing alerts: {e}")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}

def post_to_slack(message: str):
    if not SLACK_WEBHOOK_URL:
        logger.warning("SLACK_WEBHOOK_URL not configured. Skipping Slack notification.")
        return

    payload = json.dumps({"text": message}).encode("utf-8")
    req = urllib.request.Request(
        SLACK_WEBHOOK_URL,
        data=payload,
        headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req) as response:
        logger.info(f"Slack response: {response.read().decode()}")
