import json
import os
from pprint import pformat

import boto3
import pandas as pd
from chalice import Chalice

from chalicelib import utils

app = Chalice(app_name='sum-rows')
app.log.setLevel(level="INFO")

INPUT_BUCKET_NAME = os.environ["INPUT_BUCKET_NAME"]
OUTPUT_BUCKET_NAME = os.environ["OUTPUT_BUCKET_NAME"]
QUEUE_NAME = os.environ["SQS_QUEUE_NAME"]


@app.on_s3_event(
    bucket=INPUT_BUCKET_NAME,
    prefix="incoming",
    events=['s3:ObjectCreated:*']
)
def sum_rows_input(event):
    """
    Reads a DataFrame from S3 and sums up the rows. For example, given,

             0   1
        0  100  20
        1   20  30
        2   40  50

    Produces

        0    120
        1     50
        2     90

    :param event:
    :return:
    """
    s3_uri_csv = f"s3://{event.bucket}/{event.key}"
    app.log.info(f"Reading csv file from {s3_uri_csv}")
    data_df = pd.read_csv(s3_uri_csv)
    row_sums = data_df.sum(axis=1).to_dict()
    app.log.info(f"Got result: {row_sums}")

    # Send the sum to SQS
    sqs_client = boto3.client("sqs")
    message = {"row_sums": row_sums, "key": event.key}
    utils.send_sqs_message(sqs_client, QUEUE_NAME, message)


@app.on_sqs_message(queue=QUEUE_NAME, batch_size=1)
def handle_row_sum(event):
    s3_client = boto3.client("s3")

    for record in event:
        message_content = json.loads(record.body)
        app.log.info(
            f"Got message on queue [{QUEUE_NAME}]: [{pformat(message_content)}]")

        # Move file from input to output bucket
        utils.move_file(s3_client, INPUT_BUCKET_NAME, OUTPUT_BUCKET_NAME,
                        message_content["key"])
