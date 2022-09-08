import json
from typing import Dict


def send_sqs_message(sqs_client, queue_name: str, message_json: Dict[str, str]):
    """Send message to an SQS queue."""
    queue_url = sqs_client.get_queue_url(QueueName=queue_name)["QueueUrl"]
    message_body = json.dumps(message_json)
    sqs_client.send_message(QueueUrl=queue_url, MessageBody=message_body)


def move_file(s3_client, source_bucket: str , target_bucket: str, key: str):
    """Move s3://<source_bucket>/<key> to s3://<target_bucket>/<key>"""
    s3_client.copy_object(
        CopySource={"Bucket": source_bucket, "Key": key},
        Bucket=target_bucket,
        Key=key,
    )
    s3_client.delete_object(
        Bucket=source_bucket,
        Key=key,
    )
