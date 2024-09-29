import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  }

  void _startListening() async {
    if (!_isListening) {
      await _speechToText.listen(onResult: (result) {
        setState(() {
          _isListening = _speechToText.isListening;
        });

        // Process the recognized speech text here
        if (result.recognizedWords.contains('roam mode')) {
          // Navigate to Roam Mode screen
        } else if (result.recognizedWords.contains('navigate to')) {
          // Navigate to Navigation Mode screen with the destination
        }
      });
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = _speechToText.isListening;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/your_logo.png'), // Replace with your logo image path
            ElevatedButton(
              onPressed: _startListening,
              child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Roam Mode screen
                  },
                  child: const Text('Roam Mode'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Navigation Mode screen
                  },
                  child: const Text('Navigation Mode'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
