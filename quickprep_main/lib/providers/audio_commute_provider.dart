import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../services/audio_tts_service.dart';

class AudioCommuteProvider extends ChangeNotifier {
  final AudioTtsService _ttsService = AudioTtsService();
  List<Question> _playlist = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isSpeakingAnswer = false;
  double _playbackRate = 0.5; // Flutter TTS rate baseline
  Timer? _stepTimer;

  bool get isPlaying => _isPlaying;
  bool get isSpeakingAnswer => _isSpeakingAnswer;
  int get currentIndex => _currentIndex;
  double get playbackRate => _playbackRate;
  List<Question> get playlist => _playlist;

  Question? get currentQuestion =>
      _playlist.isNotEmpty && _currentIndex < _playlist.length
          ? _playlist[_currentIndex]
          : null;

  AudioCommuteProvider() {
    _ttsService.onStateChanged.listen((state) {
      if (state == TtsState.stopped && _isPlaying) {
        _handleStepComplete();
      }
    });
  }

  void startPlaylist(List<Question> questions, {int startIndex = 0}) {
    if (questions.isEmpty) return;
    _playlist = questions;
    _currentIndex = startIndex.clamp(0, questions.length - 1);
    _isPlaying = true;
    _isSpeakingAnswer = false;
    notifyListeners();
    _playCurrentStep();
  }

  void _playCurrentStep() async {
    if (!_isPlaying || currentQuestion == null) return;

    if (!_isSpeakingAnswer) {
      // Step 1: Speak Question
      await _ttsService.speak(
        'Question ${_currentIndex + 1}. ${currentQuestion!.question}',
      );
    } else {
      // Step 2: Speak Answer
      await _ttsService.speak(
        'Answer. ${currentQuestion!.answer}',
      );
    }
  }

  void _handleStepComplete() {
    if (!_isPlaying) return;

    _stepTimer?.cancel();
    if (!_isSpeakingAnswer) {
      // After question is read, brief pause then read answer
      _stepTimer = Timer(const Duration(milliseconds: 1400), () {
        if (!_isPlaying) return;
        _isSpeakingAnswer = true;
        notifyListeners();
        _playCurrentStep();
      });
    } else {
      // After answer is read, brief pause then advance to next card
      _stepTimer = Timer(const Duration(milliseconds: 2000), () {
        if (!_isPlaying) return;
        if (_currentIndex < _playlist.length - 1) {
          _currentIndex++;
          _isSpeakingAnswer = false;
          notifyListeners();
          _playCurrentStep();
        } else {
          // Reached end of playlist
          stop();
        }
      });
    }
  }

  void pause() {
    _stepTimer?.cancel();
    _isPlaying = false;
    _ttsService.pause();
    notifyListeners();
  }

  void resume() {
    if (_playlist.isEmpty) return;
    _isPlaying = true;
    notifyListeners();
    _playCurrentStep();
  }

  void next() {
    if (_currentIndex < _playlist.length - 1) {
      _stepTimer?.cancel();
      _currentIndex++;
      _isSpeakingAnswer = false;
      notifyListeners();
      if (_isPlaying) _playCurrentStep();
    }
  }

  void previous() {
    if (_currentIndex > 0) {
      _stepTimer?.cancel();
      _currentIndex--;
      _isSpeakingAnswer = false;
      notifyListeners();
      if (_isPlaying) _playCurrentStep();
    }
  }

  void stop() {
    _stepTimer?.cancel();
    _isPlaying = false;
    _isSpeakingAnswer = false;
    _ttsService.stop();
    notifyListeners();
  }

  void setPlaybackRate(double rate) {
    _playbackRate = rate;
    _ttsService.setSpeechRate(rate);
    notifyListeners();
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _ttsService.dispose();
    super.dispose();
  }
}
