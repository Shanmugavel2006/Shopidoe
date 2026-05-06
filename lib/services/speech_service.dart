import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

mixin SpeechRecognitionMixin<T extends StatefulWidget> on State<T> {
  late stt.SpeechToText speech;
  bool isListening = false;
  
  void initSpeech() {
    speech = stt.SpeechToText();
  }

  void toggleListening({
    required TextEditingController controller,
    required Function(String) onResult,
    Color primaryColor = const Color(0xFFB10044),
  }) async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (val) {
          debugPrint('Speech Status: $val');
          if (val == 'notListening' || val == 'done') {
            if (mounted) setState(() => isListening = false);
          }
        },
        onError: (val) {
          debugPrint('Speech Error: $val');
          if (mounted) {
            setState(() => isListening = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Speech error: ${val.errorMsg}')),
            );
          }
        },
      );

      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (val) {
            if (mounted) {
              controller.text = val.recognizedWords;
              onResult(val.recognizedWords);
            }
          },
          listenMode: stt.ListenMode.search,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition not available on this device')),
          );
        }
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }
}
