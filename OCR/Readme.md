# Text Extraction App with Flask and AWS Textract

This project demonstrates a Flutter application that interacts with a Flask server to extract text from images using Amazon Textract, a machine learning service that simplifies information extraction from scanned documents and images.

## Understanding the Components

- **Flutter App**: A mobile or desktop application built using the Flutter framework that provides a user interface for selecting images and displaying extracted text.
- **Flask Server**: A lightweight Python web framework that serves as an intermediary between the Flutter app and AWS Textract.
- **AWS Textract**: A managed service that uses machine learning to identify and extract text from images and documents.

## Requirements

- **Flutter SDK**: [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Python 3.x**: [Download](https://www.python.org/downloads/windows/)
- **boto3 Library**: Install using `pip install boto3`
- **AWS Account**: With Textract service enabled (free tier available)

## Setting Up AWS Textract

1. Sign in to the [AWS Management Console](https://aws.amazon.com/console/).
2. Search for "Textract" in the search bar and select the service.
3. If Textract is not enabled in your region, click on "Get Started" to activate it.
4. Note down your AWS Access Key ID, AWS Secret Access Key, and the region name for your account. These will be used later in the Python code.

## Running the Application

1. Fork this repository and clone it.

2. Navigate to the project directory:

    ```bash
    cd OCR
    ```

3. Set Up Flutter Project (if needed):
   If you haven't already, follow the [Flutter documentation](https://docs.flutter.dev/get-started/install) to set up the Flutter SDK and create a new Flutter project.

4. Run the Flask Server in the PythonFlasApp File under OCR:

    ```bash
    python app.py
    ```

   This will start the Flask server, typically running on `http://localhost:5000` by default.

5. Run the Flutter App in the Flutter App file under OCR:

   - **Using a Flutter IDE**: Open the `textract_app` directory in your Flutter IDE (e.g., Android Studio with Flutter plugin, Visual Studio Code with Flutter extension). Follow the IDE's instructions to run the app.
   - **Command-line (development mode)**:

     ```bash
     flutter run
     ```

   - **Command-line (release mode)** (For production builds):

     ```bash
     flutter build appbundle
     ```

## Interact with the App

1. Launch the Flutter app on your device or emulator.
2. Click the "Pick Image" button to select an image from your device.
3. The extracted text from the image will be displayed on the screen.

## Explanation of the Code

- **Flutter App (`textract_app.dart`)**:
  - Uses the `image_picker` package to select an image from the device.
  - Sends the image bytes to the Flask server using an HTTP POST request.
  - Displays the extracted text received from the server.

- **Flask Server (`app.py`)**:
  - Uses the `boto3` library to interact with the AWS Textract service.
  - Extracts the image bytes from the request body.
  - Calls the Textract client's `analyze_document` method to analyze the image.
  - Processes the analysis results to extract text and returns it to the Flutter app in JSON format.

## Additional Considerations

- **Error Handling**: Consider implementing proper error handling in both the Flutter and Flask code for cases where image selection fails, or the AWS Textract service encounters issues.
- **Security**: For production use, secure your AWS credentials by storing them in environment variables or using a secrets manager.


## Conclusion

This combined approach leverages the strengths of Flutter for a user-friendly interface and Flask for a lightweight server to seamlessly integrate with AWS Textract's image processing capabilities. By following these steps and customizing the code for your specific requirements, you can create a powerful text extraction application using the provided technologies.
