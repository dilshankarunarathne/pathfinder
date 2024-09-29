import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:speech_to_text/speech_to_text.dart';

class RoamModeScreen extends StatefulWidget {
  const RoamModeScreen({super.key});

  @override
  _RoamModeScreenState createState() => _RoamModeScreenState();
}

class _RoamModeScreenState extends State<RoamModeScreen> {
  // ... (camera, audio, speech recognition initialization)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Camera preview
          Expanded(
            child: CameraPreview(_controller),
          ),
          // Audio output controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: _toggleAudioOutput,
                icon: const Icon(Icons.headset),
              ),
              IconButton(
                onPressed: _toggleAudioOutput,
                icon: const Icon(Icons.speaker),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
