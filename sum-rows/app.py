import pandas as pd
from chalice import Chalice

app = Chalice(app_name='sum-rows')

INPUT_BUCKET_NAME = "chalice-demo-input-bucket"
OUTPUT_BUCKET_NAME = "chalice-demo-input-bucket"


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
