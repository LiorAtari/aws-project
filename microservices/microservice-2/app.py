import boto3
from botocore.exceptions import ClientError
from dotenv import load_dotenv
import json
import logging
import os
import time

# Load environment variables (only for non-secret values like region)
load_dotenv()

# Configure logging to show output in the terminal
logging.basicConfig(level=logging.INFO)

# Create SQS client
sqs = boto3.client('sqs')
s3 = boto3.client('s3')

queue_url = "https://sqs.eu-north-1.amazonaws.com/794038222022/stadard_queue"
bucket_name = "lioratari-bucket"

def upload_to_s3(message_body, message_id):
    try:
        object_key = f"sqs_message_{message_id}.json"
        s3.put_object(
            Bucket=bucket_name,
            Key=object_key,
            Body=json.dumps(message_body)
        )
        logging.info(f"message {message_id} pushed to S3")
    except ClientError as e:
        logging.error(f"Error uploading message {message_id} to S3: {str(e)}")

def delete_uploaded_messages(receipt_handle):
    try:
        sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )
        logging.info(f"Deleted message with receipt handle {receipt_handle}")
    except ClientError as e:
        logging.error(f"Error deleting message from sqs: {str(e)}")

def process_sqs_messages():
    try:
    # Receive message from SQS queue
        response = sqs.receive_message(
            QueueUrl=queue_url,
            AttributeNames=[
                'SentTimestamp'
            ],
            MaxNumberOfMessages=5,
            MessageAttributeNames=[
                'All'
            ],
            VisibilityTimeout=300,
            WaitTimeSeconds=0
        )
        if 'Messages' not in response:
            logging.info("No messages found in SQS")
            return
        
        for message in response['Messages']:
            message_body = message['Body']
            receipt_handle = message['ReceiptHandle']
            message_id = message['MessageId']

            upload_to_s3(message_body, message_id)
            delete_uploaded_messages(receipt_handle)

    except ClientError as e:
        logging.error(f"Error processing the SQS messages: {str(e)}")

if __name__ == '__main__':
    while True:
        process_sqs_messages()
        # Wait for a minute before polling again
        time.sleep(60)