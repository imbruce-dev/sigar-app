import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sigar/pages/CustomCameraPage.dart'; // Import de ta page CustomCamera

class StepDocumentUpload extends StatefulWidget {
  final File? capturedImage;
  final Function(File image) onImageCaptured;
  final Function(String extractedText)? onTextExtracted;

  const StepDocumentUpload({
    super.key,
    required this.capturedImage,
    required this.onImageCaptured,
    this.onTextExtracted,
  });

  @override
  State<StepDocumentUpload> createState() => _StepDocumentUploadState();
}

class _StepDocumentUploadState extends State<StepDocumentUpload> {
  Future<void> _captureImage() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      _showMessage('Permission caméra refusée.');
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomCameraPage(
          onImageCaptured: (capturedImage, extractedText) {
            Navigator.pop(context, {'image': capturedImage, 'text': extractedText});
          },
        ),
      ),
    );

    if (result != null) {
      final File capturedImage = result['image'];
      final String extractedText = result['text'];

      widget.onImageCaptured(capturedImage);
      if (widget.onTextExtracted != null) {
        widget.onTextExtracted!(extractedText);
      }
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Veuillez prendre une photo d'un document prouvant la propriété du véhicule (carte grise).",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),

        ElevatedButton.icon(
          onPressed: _captureImage,
          icon: const Icon(Icons.camera_alt),
          label: const Text("Ouvrir la caméra"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4266B5),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        if (widget.capturedImage != null)
          Stack(
            alignment: Alignment.center,
            children: [
              Image.file(
                widget.capturedImage!,
                height: 300,
                fit: BoxFit.cover,
              ),
              Positioned(
                child: Container(
                  width: 250,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 30),

        Center(
          child: Lottie.asset('lib/assets/animations/f7lPpYl4S7.json', height: 200),
        ),
      ],
    );
  }
}
