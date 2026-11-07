import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question_model.dart';
import '../models/category_model.dart';
import '../core/seed_data.dart';

class QuestionProvider extends ChangeNotifier {
  List<Category> _categories = [];
  List<Question> _questions = [];
  final Set<String> _bookmarkedIds = {};
  String? _selectedCategoryId;
  String _selectedCompanyFilter = 'All'; // All, FAANG, MNC, FinTech, Startup
  String _searchQuery = '';

  List<Category> get categories => _categories;
  List<Question> get allQuestions => _questions;
  Set<String> get bookmarkedIds => _bookmarkedIds;
  String? get selectedCategoryId => _selectedCategoryId;
  String get selectedCompanyFilter => _selectedCompanyFilter;
  String get searchQuery => _searchQuery;

  QuestionProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _categories = SeedData.categories;
    _questions = SeedData.questions;

    final prefs = await SharedPreferences.getInstance();
    final savedBookmarks =
        prefs.getStringList('quickprep_bookmarked_ids') ?? [];
    _bookmarkedIds.addAll(savedBookmarks);

    // If there are locally cached questions from admin bulk import or dynamic sync
    final cachedQuestionsStr = prefs.getString('quickprep_custom_questions');
    if (cachedQuestionsStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(cachedQuestionsStr);
        final customQuestions =
            decoded.map((e) => Question.fromJson(e)).toList();
        // Merge without duplicates
        final existingIds = _questions.map((q) => q.id).toSet();
        for (var cq in customQuestions) {
          if (!existingIds.contains(cq.id)) {
            _questions.add(cq);
          }
        }
      } catch (_) {}
    }

    notifyListeners();
  }

  List<Question> get filteredQuestions {
    return _questions.where((q) {
      // Category filter
      if (_selectedCategoryId != null && q.categoryId != _selectedCategoryId) {
        return false;
      }
      // Company filter
      if (_selectedCompanyFilter != 'All' &&
          !q.companyTags.contains(_selectedCompanyFilter)) {
        return false;
      }
      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchQ = q.question.toLowerCase().contains(query);
        final matchA = q.answer.toLowerCase().contains(query);
        final matchTags =
            q.companyTags.any((t) => t.toLowerCase().contains(query));
        if (!matchQ && !matchA && !matchTags) return false;
      }
      return true;
    }).toList();
  }

  List<Question> get bookmarkedQuestions {
    return _questions.where((q) => _bookmarkedIds.contains(q.id)).toList();
  }

  List<Question> getQuestionsByCategory(String categoryId) {
    return _questions.where((q) => q.categoryId == categoryId).toList();
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setCompanyFilter(String filter) {
    _selectedCompanyFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  bool isBookmarked(String questionId) => _bookmarkedIds.contains(questionId);

  Future<void> toggleBookmark(String questionId) async {
    if (_bookmarkedIds.contains(questionId)) {
      _bookmarkedIds.remove(questionId);
    } else {
      _bookmarkedIds.add(questionId);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'quickprep_bookmarked_ids', _bookmarkedIds.toList());
    notifyListeners();
  }

  Future<void> addCustomQuestions(List<Question> newQuestions) async {
    final existingIds = _questions.map((q) => q.id).toSet();
    for (var nq in newQuestions) {
      if (!existingIds.contains(nq.id)) {
        _questions.add(nq);
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final customList = _questions
        .where((q) => !SeedData.questions.any((sq) => sq.id == q.id))
        .map((q) => q.toJson())
        .toList();
    await prefs.setString(
        'quickprep_custom_questions', jsonEncode(customList));
    notifyListeners();
  }
}
