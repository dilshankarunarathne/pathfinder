import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class RoamModeScreen extends StatefulWidget {
  const RoamModeScreen({super.key});

  @override
  _RoamModeScreenState createState() => _RoamModeScreenState();
}

class _RoamModeScreenState extends State<RoamModeScreen> {
  CameraController? _controller;
  bool _isStreaming = false;
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  Timer? _listeningTimer;
  List<dynamic>? _recognitions;
  Interpreter? _interpreter;
  late ImageProcessor _imageProcessor;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initSpeech();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    await _controller!.initialize();
    setState(() {});
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
    _startListening(); // Start listening automatically
  }

  void _startListening() async {
    if (!_isListening) {
      await _speechToText.listen(onResult: _onSpeechResult);
      print('Listening...');
      setState(() {
        _isListening = true;
      });
    }
  }

  void _stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
      // Restart listening after a short delay
      _listeningTimer = Timer(const Duration(seconds: 5), _startListening);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final recognizedWords = result.recognizedWords.toLowerCase();
    print('-----------------Recognized words: $recognizedWords');
    if (recognizedWords.contains('go back')) {
      Navigator.pop(context);
    } else if (recognizedWords.contains('navigation')) {
      Navigator.pushNamed(context, '/navigation_mode');
    }
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/yolov2_tiny.tflite');
      _imageProcessor = ImageProcessorBuilder()
          .add(ResizeOp(416, 416, ResizeMethod.BILINEAR))
          .build();
      print('----------------Model loaded');
    } catch (e) {
      print('------------------ Failed to load model: $e');
    }
  }

  Future<void> _startStreaming() async {
    if (!_isStreaming) {
      await _controller!.startImageStream((CameraImage image) async {
        // Run the model on the image data
        _runModelOnFrame(image);
      });

      setState(() {
        _isStreaming = true;
      });
    }
  }

  Future<void> _runModelOnFrame(CameraImage image) async {
    if (_interpreter == null) return;

    // Convert image to input format
    var input = _preProcessImage(image);

    // Define output buffer
    var output = List.filled(1 * 13 * 13 * 125, 0.0).reshape([1, 13, 13, 125]);

    // Run inference
    _interpreter!.run(input.buffer.asUint8List(), output);

    // Process output
    setState(() {
      _recognitions = output;
    });
  }

  TensorImage _preProcessImage(CameraImage image) {
    // Convert CameraImage to TensorImage
    TensorImage tensorImage = _convertCameraImageToTensorImage(image);
    // Process the image
    tensorImage = _imageProcessor.process(tensorImage);
    return tensorImage;
  }

  TensorImage _convertCameraImageToTensorImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int numChannels = image.planes.length;

    // Create a buffer to hold the image data
    final buffer = Uint8List(width * height * numChannels);

    // Copy the image data into the buffer
    for (int i = 0; i < numChannels; i++) {
      final plane = image.planes[i];
      final bytesPerPixel = plane.bytesPerPixel!;
      final bytesPerRow = plane.bytesPerRow;
      final bytes = plane.bytes;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixelIndex = y * width + x;
          final byteIndex = y * bytesPerRow + x * bytesPerPixel;
          buffer[pixelIndex * numChannels + i] = bytes[byteIndex];
        }
      }
    }

    // Create a TensorBuffer from the buffer
    final tensorBuffer = TensorBuffer.createFixedSize(
      [1, height, width, numChannels],
      TfLiteType.uint8,
    );
    tensorBuffer.loadBuffer(buffer.buffer);

    // Create a TensorImage from the TensorBuffer
    final tensorImage = TensorImage.fromTensorBuffer(tensorBuffer);

    return tensorImage;
  }

  Future<void> _stopStreaming() async {
    if (_isStreaming) {
      await _controller!.stopImageStream();

      setState(() {
        _isStreaming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.asset('assets/images/logo.jpg'), // Add the logo at the top
          Expanded(
            child: _controller != null && _controller!.value.isInitialized
                ? Stack(
                    children: [
                      CameraPreview(_controller!),
                      _buildRecognitionResults(),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startStreaming,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF004D40), // Text color
                ),
                child: const Text('Start Streaming'),
              ),
              ElevatedButton(
                onPressed: _stopStreaming,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF004D40), // Text color
                ),
                child: const Text('Stop Streaming'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecognitionResults() {
    if (_recognitions == null) return Container();

    return Stack(
      children: _recognitions!.map((recognition) {
        return Positioned(
          left: recognition['rect']['x'] * MediaQuery.of(context).size.width,
          top: recognition['rect']['y'] * MediaQuery.of(context).size.height,
          width: recognition['rect']['w'] * MediaQuery.of(context).size.width,
          height: recognition['rect']['h'] * MediaQuery.of(context).size.height,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red,
                width: 3,
              ),
            ),
            child: Text(
              "${recognition['detectedClass']} ${(recognition['confidenceInClass'] * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                backgroundColor: Colors.red,
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _speechToText.stop();
    _listeningTimer?.cancel();
    _interpreter?.close();
    super.dispose();
  }
}
