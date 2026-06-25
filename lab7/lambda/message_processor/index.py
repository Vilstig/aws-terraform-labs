import json
import os
import re
import uuid
from datetime import datetime, timezone

import boto3

dynamodb = boto3.resource("dynamodb")
sns = boto3.client("sns")

TABLE_NAME = os.environ["MESSAGES_TABLE_NAME"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

CORS_HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "POST,OPTIONS",
}


def handler(event, context):
    if event.get("httpMethod") == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": "",
        }

    body = json.loads(event.get("body") or "{}")
    username = body.get("username", "Anonymous")
    message = body.get("message", "")

    contains_placki = bool(re.search(r"placki", message, re.IGNORECASE))

    message_id = str(uuid.uuid4())
    table = dynamodb.Table(TABLE_NAME)
    table.put_item(
        Item={
            "messageId": message_id,
            "username": username,
            "message": message,
            "containsPlacki": contains_placki,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    )

    if contains_placki:
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=f"Uzytkownik {username} wyslal wiadomosc zawierajaca 'placki': {message}",
            Subject="Placki Notification",
        )

    return {
        "statusCode": 200,
        "headers": CORS_HEADERS,
        "body": json.dumps(
            {
                "messageId": message_id,
                "containsPlacki": contains_placki,
            }
        ),
    }
