import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RoamModeScreen extends StatefulWidget {
  const RoamModeScreen({super.key});

  @override
  _RoamModeScreenState createState() => _RoamModeScreenState();
}

class _RoamModeScreenState extends State<RoamModeScreen> {
  CameraController? _controller;
  late WebSocketChannel _channel;
  bool _isStreaming = false;
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  Timer? _listeningTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _connectWebSocket();
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

  void _connectWebSocket() {
    _channel = IOWebSocketChannel.connect('ws://your_server_url');
    _channel.stream.listen((message) {
      // Handle server responses here
    });
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
    print('Recognized words: $recognizedWords');
    if (recognizedWords.contains('go back')) {
      Navigator.pop(context);
    } else if (recognizedWords.contains('navigation')) {
      Navigator.pushNamed(context, '/navigation_mode');
    }
  }

  Future<void> _startStreaming() async {
    if (!_isStreaming) {
      await _controller!.startImageStream((CameraImage image) async {
        // Convert image data to a format suitable for sending over WebSocket
        final bytes = image.planes.fold<Uint8List>(
          Uint8List(0),
          (Uint8List previousValue, Plane plane) =>
              Uint8List.fromList(previousValue + plane.bytes),
        );

        // Send image data to the server
        _channel.sink.add(bytes);
      });

      setState(() {
        _isStreaming = true;
      });
    }
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
                ? CameraPreview(_controller!)
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

  @override
  void dispose() {
    _controller?.dispose();
    _channel.sink.close();
    _speechToText.stop();
    _listeningTimer?.cancel();
    super.dispose();
  }
}
