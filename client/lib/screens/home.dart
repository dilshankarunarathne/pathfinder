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
          Navigator.pushNamed(context, '/roam_mode');
        } else if (result.recognizedWords.contains('navigate to')) {
          Navigator.pushNamed(context, '/navigation_mode');
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
            Image.asset('lib/assets/images/logo.jpg'),
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
    );
  }
}
