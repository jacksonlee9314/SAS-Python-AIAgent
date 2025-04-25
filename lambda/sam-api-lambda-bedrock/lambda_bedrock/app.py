import boto3
import json

bedrock_runtime = boto3.client("bedrock-runtime", region_name="ap-southeast-2")


def lambda_handler(event, context):
    # Extract the SAS code from the POST request body
    # Ensure the SAS code is passed in the body of the POST request
    # Log the full event to check its structure
    body = json.loads(event['body'])  # Parse the stringified JSON
    sas_code = body.get('sas_code', '')

    if not sas_code:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "No SAS code provided"})
        }

    # Format the request payload
    request_payload = {
        "modelId": "anthropic.claude-3-sonnet-20240229-v1:0",
        "contentType": "application/json",
        "accept": "application/json",
        "body": json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": 1000,
            "messages": [
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": f"You are a senior data engineer. Translate the following SAS code into Python just give me the python script only the response should not include anything outside python code:\n\n{sas_code}"
                        }
                    ]
                }
            ]
        })
    }

    # Send the request to Bedrock
    response = bedrock_runtime.invoke_model(**request_payload)

    # Return the response from the model
    return {
        "statusCode": 200,
        "body": json.loads(response['body'].read().decode())
    }
