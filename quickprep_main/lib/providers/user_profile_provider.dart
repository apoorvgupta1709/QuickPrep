import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_model.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';

class UserProfileProvider extends ChangeNotifier {
  UserProfile _profile = const UserProfile();
  bool _isLoaded = false;
  bool _filterByTrackOnly = false;

  UserProfile get profile => _profile;
  bool get isLoaded => _isLoaded;
  bool get isCompleted => _profile.isCompleted;
  bool get filterByTrackOnly => _filterByTrackOnly;

  UserProfileProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('quickprep_user_profile');
      if (jsonStr != null) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        _profile = UserProfile.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('UserProfile load error: $e');
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile newProfile) async {
    _profile = newProfile.copyWith(isCompleted: true);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'quickprep_user_profile', jsonEncode(_profile.toJson()));
    } catch (e) {
      debugPrint('UserProfile save error: $e');
    }
  }

  void toggleFilterByTrack(bool value) {
    _filterByTrackOnly = value;
    notifyListeners();
  }

  /// Map each career profession to its primary topic/category IDs
  List<String> getRecommendedCategoryIds() {
    switch (_profile.profession) {
      case CareerRoles.frontend:
        return ['dsa', 'system_design', 'flutter_dart'];
      case CareerRoles.backend:
        return ['system_design', 'sql_db', 'python', 'java_oop'];
      case CareerRoles.fullstack:
        return ['system_design', 'sql_db', 'python', 'dsa'];
      case CareerRoles.mobile:
        return ['flutter_dart', 'system_design', 'dsa', 'java_oop'];
      case CareerRoles.devops:
        return ['system_design', 'sql_db', 'python'];
      case CareerRoles.dataAi:
        return ['python', 'sql_db', 'dsa'];
      case CareerRoles.fresher:
        return ['dsa', 'java_oop', 'sql_db', 'python'];
      case CareerRoles.architect:
        return ['system_design', 'sql_db', 'java_oop'];
      default:
        return ['system_design', 'sql_db', 'dsa'];
    }
  }

  List<Category> filterCategories(List<Category> allCategories) {
    if (!_filterByTrackOnly) return allCategories;
    final recommendedIds = getRecommendedCategoryIds();
    final filtered =
        allCategories.where((c) => recommendedIds.contains(c.id)).toList();
    return filtered.isNotEmpty ? filtered : allCategories;
  }

  List<Question> filterQuestions(List<Question> questions) {
    if (!_filterByTrackOnly) return questions;
    final recommendedIds = getRecommendedCategoryIds();
    final filtered =
        questions.where((q) => recommendedIds.contains(q.categoryId)).toList();
    return filtered.isNotEmpty ? filtered : questions;
  }
}
