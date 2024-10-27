import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class RoamModeScreen extends StatefulWidget {
  const RoamModeScreen({super.key});

  @override
  _RoamModeScreenState createState() => _RoamModeScreenState();
}

class _RoamModeScreenState extends State<RoamModeScreen> {
  CameraController? _controller;
  final bool _isStreaming = false;
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  Timer? _listeningTimer;
  List<dynamic>? _recognitions;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initSpeech();
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

  Future<void> _captureAndSendImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      print("Camera is not initialized");
      return;
    }

    try {
      final image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();

      // Send bytes to server
      await _sendImageToServer(bytes);
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  Future<void> _sendImageToServer(Uint8List bytes) async {
    final uri = Uri.parse('http://127.0.0.1:8000/predict');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: 'frame.jpg'));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decodedData = jsonDecode(responseData);
      setState(() {
        _recognitions = decodedData['objects'];
      });
    } else {
      print('Failed to send image to server: ${response.statusCode}');
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
                onPressed: _captureAndSendImage,
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

    print("----------- recognitions: $_recognitions");

    return Stack(
      children: _recognitions!.map((recognition) {
        final rect = recognition['rect'];
        final x = double.tryParse(rect['x'].toString()) ?? 0.0;
        final y = double.tryParse(rect['y'].toString()) ?? 0.0;
        final w = double.tryParse(rect['w'].toString()) ?? 0.0;
        final h = double.tryParse(rect['h'].toString()) ?? 0.0;

        return Positioned(
          left: x * MediaQuery.of(context).size.width,
          top: y * MediaQuery.of(context).size.height,
          width: w * MediaQuery.of(context).size.width,
          height: h * MediaQuery.of(context).size.height,
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

  void _stopStreaming() {
    // Implement your stop streaming logic here
    print('Stop streaming');
  }

  @override
  void dispose() {
    _controller?.dispose();
    _speechToText.stop();
    _listeningTimer?.cancel();
    super.dispose();
  }
}
