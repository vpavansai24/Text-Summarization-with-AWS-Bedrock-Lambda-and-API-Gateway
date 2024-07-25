import json
import boto3

bedrock_client = boto3.client('bedrock-runtime')

def lambda_handler(event, context):

    print("Event:", event)

    # Parse the JSON body
    body = json.loads(event['body'])

    # Extract the 'prompt' field
    prompt = body.get('prompt', '')
    
    print("Prompt:", prompt)
   
    # Create  Request Syntax - Get details from console & body should be json object - use json.dumps for body
    bedrock_response = bedrock_client.invoke_model(
       contentType='application/json',
       accept='application/json',
       modelId='cohere.command-light-text-v14',
       body=json.dumps({
        "prompt": prompt,
        "temperature": 0.9,
        "p": 0.75,
        "k": 0,
        "max_tokens": 100}))

    # Convert Streaming Body to Byte(.read method) and then Byte to String using json.loads#
    bedrock_response_byte = bedrock_response['body'].read()
    bedrock_response_string = json.loads(bedrock_response_byte)

    # Update the 'return' by changing the 'body'
    client_final_response = bedrock_response_string['generations'][0]['text']
    print("Response:", client_final_response)

    return {
        'statusCode': 200,
        'body': json.dumps(client_final_response)
    }