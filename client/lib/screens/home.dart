import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../components/navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
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
      Future.delayed(const Duration(seconds: 1), _startListening);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final recognizedWords = result.recognizedWords.toLowerCase();
    print('Recognized words: $recognizedWords');
    if (recognizedWords.contains('camera')) {
      Navigator.pushNamed(context, '/roam_mode');
    } else if (recognizedWords.contains('navigate to')) {
      final placeName = recognizedWords.split('navigate to ').last;
      // You need to implement a method to get coordinates from the place name
      final coordinates = _getCoordinatesFromPlaceName(placeName);
      Navigator.pushNamed(context, '/navigation_mode', arguments: coordinates);
    }
  }

  // Dummy method to get coordinates from place name
  // You need to implement this method to get actual coordinates
  Map<String, double> _getCoordinatesFromPlaceName(String placeName) {
    // Replace this with actual implementation
    return {'latitude': 37.7749, 'longitude': -122.4194}; // Example coordinates
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pathfinder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.jpg',
                width: 100, height: 100), // Add the logo at the top
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/roam_mode');
                  },
                  child: const Text('Roam Mode'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/navigation_mode');
                  },
                  child: const Text('Navigation Mode'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(), // Add the BottomNavBar widget
    );
  }
}
