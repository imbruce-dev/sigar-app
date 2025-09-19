import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CustomCameraPage extends StatefulWidget {
  final Function(File capturedImage, String extractedText) onImageCaptured;

  const CustomCameraPage({super.key, required this.onImageCaptured});

  @override
  State<CustomCameraPage> createState() => _CustomCameraPageState();
}

class _CustomCameraPageState extends State<CustomCameraPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  Future<void> _captureAndProcessImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    setState(() => _isProcessing = true);

    final XFile file = await _cameraController!.takePicture();
    final File capturedImage = File(file.path);

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(
      InputImage.fromFile(capturedImage),
    );
    final extractedText = recognizedText.text;
    await textRecognizer.close();

    widget.onImageCaptured(capturedImage, extractedText);

    setState(() => _isProcessing = false);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          _buildOverlay(), // ➔ Zone du rectangle
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            bottom: 40,
            left: MediaQuery.of(context).size.width * 0.5 - 30,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _isProcessing ? null : _captureAndProcessImage,
              child: const Icon(Icons.camera, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.25,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}
