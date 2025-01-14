import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CaptureImageScreen extends StatefulWidget {
  const CaptureImageScreen({super.key});

  @override
  _CaptureImageScreenState createState() => _CaptureImageScreenState();
}

class _CaptureImageScreenState extends State<CaptureImageScreen> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  String? extractedJson;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Initialize Camera
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;
      _controller = CameraController(firstCamera, ResolutionPreset.medium);
      _initializeControllerFuture = _controller.initialize();
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing camera: $e');
      }
    }
  }

  /// Capture and Process Image
  Future<void> _captureAndProcessImage() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _initializeControllerFuture;

      /// Capture the image
      final image = await _controller.takePicture();

      /// Process the image with Google ML Kit
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final inputImage = InputImage.fromFile(File(image.path));
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      /// Convert the extracted text to JSON
      final extractedText = recognizedText.text;
      final jsonText = jsonEncode({'text': extractedText});

      setState(() {
        extractedJson = jsonText;
      });

      textRecognizer.close();
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Failed to process image'),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Capture and Extract Text',
          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error initializing camera.'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          if (extractedJson != null)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 80),
                child: Text(
                  extractedJson!,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: ElevatedButton(
          onPressed: isLoading ? null : _captureAndProcessImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLoading ? Colors.blue : Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 15),
          ),
          child: isLoading ?
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Processing...',
                style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ) :
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Scan',
                style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }
}
