import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class HomeScreen extends StatefulWidget {
  final CameraDescription camera;
  const HomeScreen({super.key, required this.camera});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController controller;
  late Future<void> initializeController;
  final TextRecognizer textRecognizer = TextRecognizer();
  String recognizedText = "";
  final FlutterTts flutterTts=FlutterTts();


  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.high);
    initializeController = controller.initialize().then((_) {
      startStreaming();
    });
    flutterTts.setLanguage("en-US");
  }

  void startStreaming() {
    controller.startImageStream((CameraImage cameraImage) async {
      final inputImage = await processCameraImage(cameraImage);
      if (inputImage != null) {
        detectText(inputImage);
      }
    });
  }

  Future<InputImage?> processCameraImage(CameraImage cameraImage) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in cameraImage.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

    final InputImageRotation imageRotation = InputImageRotation.rotation0deg;
    final InputImageFormat inputImageFormat = InputImageFormat.nv21;

    // Create InputImageData without plane data
    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: cameraImage.planes[0].bytesPerRow,
    );

    // Create InputImage
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: inputImageMetadata,
    );
  }

  Future<void> detectText(InputImage inputImage) async {
    final RecognizedText recognizedTextResult = await textRecognizer.processImage(inputImage);
    setState(() {
      recognizedText = recognizedTextResult.text;
    });
    flutterTts.speak(recognizedText);
  }

  @override
  void dispose() {
    controller.dispose();
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Real-time OCR')),
      body: FutureBuilder<void>(
        future: initializeController,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(controller),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    color: Colors.black54,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      recognizedText,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
