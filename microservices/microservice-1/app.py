from flask import Flask, request, jsonify
import boto3
from botocore.exceptions import ClientError
from dotenv import load_dotenv
import json
import logging
import os

# Load environment variables (only for non-secret values like region)
load_dotenv()

# Flask app
app = Flask(__name__)

# Configure logging to show output in the terminal
logging.basicConfig(level=logging.INFO)

# AWS Secrets Manager Client
def get_secrets_manager_client():
    session = boto3.Session()
    return session.client('secretsmanager')

def get_sqs_client():
    session = boto3.Session()
    return session.client('sqs')

# Function to get secret from AWS Secrets Manager
def get_secret():
    secret_name = "token"
    region_name = "eu-north-1"

    client = get_secrets_manager_client()

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
        
        # Check if 'SecretString' exists in the response
        if 'SecretString' in get_secret_value_response:
            secret = get_secret_value_response['SecretString']
            logging.info(f"Retrieved secret from Secrets Manager: '{secret}'")

            # Parse the secret as JSON (since it's in the format {"token": "lior"})
            secret_dict = json.loads(secret)  # Convert the JSON string to a dictionary
            return secret_dict.get("token")   # Extract the 'token' field from the JSON

        else:
            logging.error("Error: SecretString is not available in the response.")
            return None

    except ClientError as e:
        logging.error(f"Error retrieving secret from Secrets Manager: {e}")
        return None
    except json.JSONDecodeError:
        logging.error("Error: Secret is not in valid JSON format.")
        return None

# Helper function to validate the payload fields
def validate_payload(payload):
    required_fields = ["email_subject", "email_sender", "email_timestream", "email_content"]
    data = payload.get('data', {})
    token = payload.get('token', '')

    # Check if all required fields are present in the data
    for field in required_fields:
        if field not in data:
            return False, f"Missing field: {field}"

    # Retrieve and validate token
    stored_token = get_secret()
    if not stored_token:
        return False, "Failed to retrieve token from Secrets Manager."

    logging.info(f"Received token from request: '{token}'")
    logging.info(f"Stored token from Secrets Manager: '{stored_token}'")

    # Validate the token by stripping any leading/trailing spaces
    if stored_token.strip() != token.strip():
        return False, "Invalid token."

    return True, "Payload valid."

def send_to_sqs(data, message_attributes=None):
    sqs_client = get_sqs_client()
    queue_url = os.getenv('SQS_QUEUE_URL')
    if not message_attributes:
        message_attributes = {}
    try:
        response = sqs_client.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps(data), MessageAttributes=message_attributes
        )
        logging.info(f"Message sent to SQS. MessageId: {response['MessageId']}")
        return True
    except ClientError as error:
        logging.error(f"Error sending message to SQS: {error}")
        return False

# Route to handle incoming POST requests and validate payload
@app.route('/', methods=['POST'])
def process_request():
    payload = request.json
    logging.info(f"Received payload: {payload}")

    # Validate the incoming payload
    is_valid, message = validate_payload(payload)
    if not is_valid:
        return jsonify({"status": "error", "message": message}), 400
    data = payload.get('data', {})
    if send_to_sqs(data):
        return jsonify({"status": "success", "message": "Payload and token are valid, data sent to SQS."}), 200
    else:
        return jsonify({"status": "error", "message": "Failed to send data to SQS."}), 500

# Run the Flask app on port 8080
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
#asd
