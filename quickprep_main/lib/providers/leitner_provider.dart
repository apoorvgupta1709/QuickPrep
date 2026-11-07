import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leitner_model.dart';
import '../models/question_model.dart';

class LeitnerProvider extends ChangeNotifier {
  final Map<String, LeitnerCard> _cards = {};

  Map<String, LeitnerCard> get cards => _cards;

  LeitnerProvider() {
    _loadCards();
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('quickprep_leitner_cards');
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        decoded.forEach((key, val) {
          _cards[key] = LeitnerCard.fromJson(val);
        });
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> map = {};
    _cards.forEach((key, card) {
      map[key] = card.toJson();
    });
    await prefs.setString('quickprep_leitner_cards', jsonEncode(map));
  }

  LeitnerCard getOrCreateCard(String questionId) {
    if (!_cards.containsKey(questionId)) {
      _cards[questionId] = LeitnerCard(
        questionId: questionId,
        boxNumber: 1,
        nextReviewDate: DateTime.now(),
        lastReviewedAt: DateTime.now(),
      );
      _saveCards();
    }
    return _cards[questionId]!;
  }

  void rateCard(String questionId, bool remembered) {
    final card = getOrCreateCard(questionId);
    if (remembered) {
      card.markCorrect();
    } else {
      card.markIncorrect();
    }
    _saveCards();
    notifyListeners();
  }

  List<Question> getDueQuestions(List<Question> allQuestions) {
    return allQuestions.where((q) {
      final card = _cards[q.id];
      if (card == null) return true; // Unreviewed cards are due
      return card.isDue;
    }).toList();
  }

  int getCardCountInBox(int boxNumber, List<Question> allQuestions) {
    if (boxNumber == 1) {
      // Unreviewed questions count as Box 1
      final unreviewedCount =
          allQuestions.where((q) => !_cards.containsKey(q.id)).length;
      final box1Count =
          _cards.values.where((c) => c.boxNumber == 1).length;
      return unreviewedCount + box1Count;
    }
    return _cards.values.where((c) => c.boxNumber == boxNumber).length;
  }

  int getBoxForQuestion(String questionId) {
    return _cards[questionId]?.boxNumber ?? 1;
  }
}
