import 'package:flutter/foundation.dart';
import '../models/admin_question_model.dart';
import '../services/admin_storage_service.dart';

class AdminCmsProvider extends ChangeNotifier {
  List<AdminQuestion> _questions = [];
  String _searchQuery = '';
  String? _selectedCategory;

  List<AdminQuestion> get allQuestions => _questions;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  AdminCmsProvider() {
    _init();
  }

  Future<void> _init() async {
    _questions = await AdminStorageService.loadQuestions();
    notifyListeners();
  }

  List<AdminQuestion> get filteredQuestions {
    return _questions.where((q) {
      if (_selectedCategory != null && q.categoryId != _selectedCategory) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchQ = q.question.toLowerCase().contains(query);
        final matchA = q.answer.toLowerCase().contains(query);
        final matchCat = q.categoryName.toLowerCase().contains(query);
        if (!matchQ && !matchA && !matchCat) return false;
      }
      return true;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String? categoryId) {
    _selectedCategory = categoryId;
    notifyListeners();
  }

  Future<void> saveQuestion(AdminQuestion question) async {
    final index = _questions.indexWhere((q) => q.id == question.id);
    if (index >= 0) {
      _questions[index] = question;
    } else {
      _questions.insert(0, question);
    }
    await AdminStorageService.saveQuestions(_questions);
    notifyListeners();
  }

  Future<void> deleteQuestion(String id) async {
    _questions.removeWhere((q) => q.id == id);
    await AdminStorageService.saveQuestions(_questions);
    notifyListeners();
  }

  Future<int> bulkImportQuestions(List<AdminQuestion> incoming) async {
    final existingIds = _questions.map((q) => q.id).toSet();
    int addedCount = 0;
    for (var q in incoming) {
      if (!existingIds.contains(q.id)) {
        _questions.insert(0, q);
        addedCount++;
      }
    }
    await AdminStorageService.saveQuestions(_questions);
    notifyListeners();
    return addedCount;
  }
}
