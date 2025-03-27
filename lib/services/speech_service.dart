import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';

class SpeechService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';
  double _confidence = 0.0;
  Function(String)? onSpeechComplete;

  bool get isListening => _isListening;
  String get text => _text;
  double get confidence => _confidence;

  Future<bool> initialize() async {
    try {
      print('Initializing speech service...'); // Debug print
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech status: $status'); // Debug print
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            if (_text.isNotEmpty && onSpeechComplete != null) {
              onSpeechComplete!(_text);
            }
            notifyListeners();
          }
        },
        onError: (error) {
          print('Speech error: $error'); // Debug print
          _isListening = false;
          notifyListeners();
        },
      );
      print('Speech initialization result: $available'); // Debug print
      return available;
    } catch (e) {
      print('Speech initialization error: $e');
      return false;
    }
  }

  Future<void> startListening({Function(String)? onComplete}) async {
    if (!_isListening) {
      _text = '';
      onSpeechComplete = onComplete;
      bool available = await _speech.initialize();
      if (available) {
        print('Starting speech recognition...'); // Debug print
        _isListening = true;
        notifyListeners();
        
        await _speech.listen(
          onResult: (result) {
            print('Speech result: ${result.recognizedWords}'); // Debug print
            _text = result.recognizedWords;
            _confidence = result.confidence;
            notifyListeners();
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 2), // Reduced pause time
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      } else {
        print('Speech recognition not available'); // Debug print
      }
    }
  }

  Future<void> stopListening() async {
    print('Stopping speech recognition...'); // Debug print
    await _speech.stop();
    _isListening = false;
    if (_text.isNotEmpty && onSpeechComplete != null) {
      onSpeechComplete!(_text);
    }
    notifyListeners();
  }

  void clear() {
    _text = '';
    onSpeechComplete = null;
    notifyListeners();
  }
} 