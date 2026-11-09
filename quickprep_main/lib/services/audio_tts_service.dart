import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, paused, stopped }

class AudioTtsService {
  FlutterTts? _flutterTts;
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
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }
    try {
      _flutterTts = FlutterTts();
      await _flutterTts!.setLanguage('en-US');
      await _flutterTts!.setSpeechRate(_speechRate);
      await _flutterTts!.setPitch(_pitch);

      _flutterTts!.setStartHandler(() {
        _state = TtsState.playing;
        if (!_stateController.isClosed) _stateController.add(_state);
      });

      _flutterTts!.setCompletionHandler(() {
        _state = TtsState.stopped;
        if (!_stateController.isClosed) _stateController.add(_state);
      });

      _flutterTts!.setPauseHandler(() {
        _state = TtsState.paused;
        if (!_stateController.isClosed) _stateController.add(_state);
      });

      _flutterTts!.setContinueHandler(() {
        _state = TtsState.playing;
        if (!_stateController.isClosed) _stateController.add(_state);
      });

      _flutterTts!.setErrorHandler((msg) {
        _state = TtsState.stopped;
        if (!_stateController.isClosed) _stateController.add(_state);
      });
    } catch (e) {
      debugPrint('TTS initialization fallback: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    try {
      if (_flutterTts != null) {
        await _flutterTts!.setSpeechRate(rate);
      }
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    try {
      if (_flutterTts != null) {
        _state = TtsState.playing;
        if (!_stateController.isClosed) _stateController.add(_state);
        await _flutterTts!.speak(text);
      }
    } catch (_) {
      _state = TtsState.stopped;
      if (!_stateController.isClosed) _stateController.add(_state);
    }
  }

  Future<void> pause() async {
    try {
      if (_flutterTts != null) {
        await _flutterTts!.pause();
        _state = TtsState.paused;
        if (!_stateController.isClosed) _stateController.add(_state);
      }
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      if (_flutterTts != null) {
        await _flutterTts!.stop();
        _state = TtsState.stopped;
        if (!_stateController.isClosed) _stateController.add(_state);
      }
    } catch (_) {}
  }

  void dispose() {
    stop();
    _stateController.close();
  }
}
