import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  Timer? _listeningTimer;
  Timer? _responseTimer;
  Timer? _restartListeningTimer;
  List<dynamic>? _recognitions;
  bool _waitingForResponse = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initSpeech();
    _initTts();
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

    // Start capturing and sending images
    _captureAndSendImage();
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
    _startListening(); // Start listening automatically
  }

  void _initTts() {
    _flutterTts.setCompletionHandler(() {
      // Capture and send the next image after TTS finishes speaking
      _captureAndSendImage();
    });
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
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) async {
    final recognizedWords = result.recognizedWords.toLowerCase();
    print('Recognized words: $recognizedWords');
    if (recognizedWords.contains('go back')) {
      Navigator.pop(context);
    } else if (recognizedWords.contains('home')) {
      Navigator.pushNamed(context, '/');
    } else if (recognizedWords.contains('navigation')) {
      Navigator.pushNamed(context, '/navigation_mode');
    }

    // Stop listening and wait for 2 seconds before restarting
    _stopListening();
    await Future.delayed(const Duration(seconds: 2));
    _startListening();
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

    _waitingForResponse = true;

    // Set a timer to resend the image if no response is received within 7 seconds
    _responseTimer = Timer(const Duration(seconds: 7), () {
      if (_waitingForResponse) {
        print('No response received within 7 seconds, resending image...');
        _sendImageToServer(bytes);
      }
    });

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final decodedData = jsonDecode(responseData);
      setState(() {
        _recognitions = decodedData['objects'];
        print('Recognitions: $responseData');
        _speakRecognitions();
      });
      _waitingForResponse = false;
      _responseTimer?.cancel();
    } else {
      print('Failed to send image to server: ${response.statusCode}');
      _waitingForResponse = false;
      _responseTimer?.cancel();
      // Retry sending the image
      _captureAndSendImage();
    }
  }

  Future<void> _speakRecognitions() async {
    if (_recognitions != null && _recognitions!.isNotEmpty) {
      final text = 'Recognized objects: ${_recognitions!.join(', ')}';
      await _flutterTts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _controller != null && _controller!.value.isInitialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          if (_recognitions != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recognitions: ${_recognitions!.join(', ')}',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _speechToText.stop();
    _listeningTimer?.cancel();
    _responseTimer?.cancel();
    _restartListeningTimer?.cancel();
    super.dispose();
  }
}
