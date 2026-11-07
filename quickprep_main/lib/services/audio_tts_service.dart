import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, paused, stopped }

class AudioTtsService {
  final FlutterTts _flutterTts = FlutterTts();
  TtsState _state = TtsState.stopped;
  double _speechRate = 0.5; // standard natural rate
  final double _pitch = 1.0;

  TtsState get state => _state;
  double get speechRate => _speechRate;

  final StreamController<TtsState> _stateController =
      StreamController<TtsState>.broadcast();
  Stream<TtsState> get onStateChanged => _stateController.stream;

  AudioTtsService() {
    _initTts();
  }

  void _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(_pitch);

      _flutterTts.setStartHandler(() {
        _state = TtsState.playing;
        _stateController.add(_state);
      });

      _flutterTts.setCompletionHandler(() {
        _state = TtsState.stopped;
        _stateController.add(_state);
      });

      _flutterTts.setPauseHandler(() {
        _state = TtsState.paused;
        _stateController.add(_state);
      });

      _flutterTts.setContinueHandler(() {
        _state = TtsState.playing;
        _stateController.add(_state);
      });

      _flutterTts.setErrorHandler((msg) {
        _state = TtsState.stopped;
        _stateController.add(_state);
      });
    } catch (_) {
      // Graceful fallback on unsupported platforms / testing
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (_) {}
  }

  Future<void> speakCard(String question, String answer) async {
    final speechText = "Question: $question. Answer: $answer";
    await speak(speechText);
  }

  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _state = TtsState.stopped;
      _stateController.add(_state);
    } catch (_) {}
  }

  void dispose() {
    _flutterTts.stop();
    _stateController.close();
  }
}
