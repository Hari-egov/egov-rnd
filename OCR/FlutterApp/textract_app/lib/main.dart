import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String extractedText = '';

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageFile = File(image.path);
      await extractTextFromImage(imageFile);
    }
  }

  Future<void> extractTextFromImage(File imageFile) async {
    final url = Uri.parse('http://<YOUR-IP-ADDRESS>>:5000/extract_text');
    final imageBytes = await imageFile.readAsBytes();

    try {
      final response = await http.post(
        url,
        body: imageBytes,
        headers: {'Content-Type': 'application/octet-stream'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          extractedText = data['extracted_text'];
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Text Extraction App'),
        ),
        body: SingleChildScrollView( // Make the entire body scrollable
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Start content at top
            children: <Widget>[
              ElevatedButton(
                onPressed: pickImage,
                child: Text('Pick Image'),
              ),
              SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(maxWidth: 300),
                child: Text(
                  extractedText,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'monospace', // Preformatted font for better readability
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
