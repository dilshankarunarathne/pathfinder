import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class RoamScreen extends StatefulWidget {
  const RoamScreen({super.key});

  @override
  _RoamScreenState createState() => _RoamScreenState();
}

class _RoamScreenState extends State<RoamScreen> {
  late AudioPlayer _controller;
  bool _isSpeakerOn = false;

  @override
  void initState() {
    super.initState();
    _controller = AudioPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleAudioOutput() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
      if (_isSpeakerOn) {
        _controller.setAudioContext(AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
          ),
        ));
      } else {
        _controller.setAudioContext(AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
          ),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roam Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _toggleAudioOutput,
              child: Text(
                  _isSpeakerOn ? 'Switch to Earpiece' : 'Switch to Speaker'),
            ),
            // Add other UI components here
          ],
        ),
      ),
    );
  }
}
