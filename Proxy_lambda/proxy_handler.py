import json
import boto3

lambda_client = boto3.client('lambda')

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        if 'base64_image' not in body:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Missing base64_image in request'})
            }
        
        response = lambda_client.invoke(
            FunctionName='TextRecognitionLambda',
            InvocationType='RequestResponse',
            Payload=json.dumps({'base64_image': body['base64_image']})
        )
        return {
            'statusCode': 200,
            'body': response['Payload'].read().decode('utf-8')
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
