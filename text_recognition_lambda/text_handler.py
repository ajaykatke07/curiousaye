import base64
import boto3
import pytesseract
from PIL import Image
import io

rekognition = boto3.client('rekognition')

def lambda_handler(event, context):
    try:
        body = event
        image_data = base64.b64decode(body['base64_image'])

        # Pre-processing the image
        image = Image.open(io.BytesIO(image_data))
        processed_image = image.convert('L')  # Convert to grayscale

        # Method 1: AWS Rekognition
        rekognition_response = rekognition.detect_text(
            Image={'Bytes': image_data}
        )
        rekognition_texts = [item['DetectedText'] for item in rekognition_response['TextDetections']]
        rekognition_conf = max([item['Confidence'] for item in rekognition_response['TextDetections']])

        # Method 2: Pytesseract OCR
        pytesseract_text = pytesseract.image_to_string(processed_image)
        pytesseract_conf = 95  # Assume a default confidence for pytesseract (can refine further)

        # Compare confidence
        if rekognition_conf >= pytesseract_conf:
            result = {"method": "rekognition", "text": rekognition_texts, "confidence": rekognition_conf}
        else:
            result = {"method": "pytesseract", "text": pytesseract_text.strip(), "confidence": pytesseract_conf}

        return {
            'statusCode': 200,
            'body': result
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': {'error': str(e)}
        }
