from flask import Flask, request, jsonify
import boto3
import json

app = Flask(__name__)

# Configure AWS Textract client (replace with your credentials)
textract = boto3.client(
    'textract',
    aws_access_key_id='ACCESS_KEY_ID',
    aws_secret_access_key='SECRET_ACCESS_KEY',
    region_name='REGION'
)

@app.route('/extract_text', methods=['POST'])
def extract_text():
    if request.method == 'POST':
        try:
            # Get image data from request (replace with actual image handling)
            image_bytes = request.data  # Assuming image data is sent directly in request body

            # Call AWS Textract
            response = textract.detect_document_text(
                Document={
                    'Bytes': image_bytes,
                }
            )

            # Extract text from response (handle potential errors)
            blocks = response['Blocks']
            extracted_text = ''
            for block in blocks:
                if block['BlockType'] == 'LINE':
                    extracted_text += block['Text'] + '\n'

            return jsonify({'extracted_text': extracted_text})

        except Exception as e:
            print(f"Error extracting text: {e}")
            return jsonify({'error': 'Failed to extract text'}), 500

    return jsonify({'error': 'Invalid request method'}), 405

if __name__ == '__main__':
    app.run(debug=True)
