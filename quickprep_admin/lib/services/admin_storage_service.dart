import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_question_model.dart';
import '../models/monetization_config_model.dart';
import '../models/flagged_report_model.dart';
import '../models/broadcast_announcement_model.dart';

class AdminStorageService {
  static const String _keyQuestions = 'quickprep_admin_questions';
  static const String _keyMonetization = 'quickprep_admin_monetization';
  static const String _keyFlagged = 'quickprep_flagged_reports';
  static const String _keyBroadcasts = 'quickprep_admin_broadcasts';

  // Questions Bank
  static Future<List<AdminQuestion>> loadQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyQuestions);
    if (jsonStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((e) => AdminQuestion.fromJson(e)).toList();
      } catch (_) {}
    }
    return _getInitialAdminQuestions();
  }

  static Future<void> saveQuestions(List<AdminQuestion> questions) async {
    final prefs = await SharedPreferences.getInstance();
    final list = questions.map((q) => q.toJson()).toList();
    await prefs.setString(_keyQuestions, jsonEncode(list));
  }

  // Monetization Config
  static Future<MonetizationConfig> loadMonetizationConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyMonetization);
    if (jsonStr != null) {
      try {
        return MonetizationConfig.fromJson(jsonDecode(jsonStr));
      } catch (_) {}
    }
    return MonetizationConfig();
  }

  static Future<void> saveMonetizationConfig(MonetizationConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    config.updatedAt = DateTime.now();
    await prefs.setString(_keyMonetization, jsonEncode(config.toJson()));
  }

  // Flagged Typo/Bug Reports
  static Future<List<FlaggedReport>> loadFlaggedReports() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyFlagged) ?? [];
    if (list.isEmpty) {
      return _getSeedFlaggedReports();
    }
    return list.map((e) => FlaggedReport.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> saveFlaggedReports(List<FlaggedReport> reports) async {
    final prefs = await SharedPreferences.getInstance();
    final list = reports.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_keyFlagged, list);
  }

  // Push Broadcasts & Announcements
  static Future<List<BroadcastAnnouncement>> loadBroadcasts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyBroadcasts);
    if (jsonStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        return decoded.map((e) => BroadcastAnnouncement.fromJson(e)).toList();
      } catch (_) {}
    }
    return _getSeedBroadcasts();
  }

  static Future<void> saveBroadcasts(List<BroadcastAnnouncement> broadcasts) async {
    final prefs = await SharedPreferences.getInstance();
    final list = broadcasts.map((b) => b.toJson()).toList();
    await prefs.setString(_keyBroadcasts, jsonEncode(list));
  }

  static List<AdminQuestion> _getInitialAdminQuestions() {
    return [
      AdminQuestion(
        id: 'q_admin_1',
        categoryId: 'dsa',
        categoryName: 'Data Structures & Algo',
        question: 'What is the time complexity difference between Array Search and Hash Table Lookup?',
        answer: 'Unsorted Array linear search is O(n). A Hash Table provides average O(1) time complexity using hash buckets.',
        codeSnippet: 'final map = {"twoSum": 15};\nprint(map["twoSum"]);',
        language: 'dart',
        companyTags: ['FAANG', 'FinTech'],
        difficulty: 'Easy',
        deepDiveExplanation: 'Hash maps compute index via hash function mod capacity.',
        quizOptions: [
          'Array O(1), Hash Table O(n)',
          'Array O(n), Hash Table O(1) average',
          'Both are always O(log n)',
          'Both are always O(n)'
        ],
        correctOptionIndex: 1,
      ),
      AdminQuestion(
        id: 'q_admin_2',
        categoryId: 'flutter_dart',
        categoryName: 'Flutter & Dart',
        question: 'What is the role of the Dart Event Loop and Microtask Queue?',
        answer: 'Dart single-threaded event loop processes microtasks before event queue items.',
        codeSnippet: 'scheduleMicrotask(() => print("microtask"));',
        language: 'dart',
        companyTags: ['FAANG', 'MNC'],
        difficulty: 'Medium',
        deepDiveExplanation: 'Microtask queue drains completely before any new event queue task runs.',
        quizOptions: [
          'Event queue runs before microtasks',
          'Microtask queue runs before event queue items',
          'Separate OS threads',
          'No event loop in Dart'
        ],
        correctOptionIndex: 1,
      ),
    ];
  }

  static List<FlaggedReport> _getSeedFlaggedReports() {
    return [
      FlaggedReport(
        id: 'rep_1',
        questionId: 'dsa_1',
        questionTitle: 'Array Search vs Hash Table Lookup',
        issueType: 'Typo in Question',
        userComment: 'Minor spelling mistake in the deep dive paragraph for separate chaining.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        status: 'pending',
      ),
      FlaggedReport(
        id: 'rep_2',
        questionId: 'flt_2',
        questionTitle: 'Three trees in Flutter',
        issueType: 'Clarification',
        userComment: 'Could you add RenderObject hit testing details in the explanation?',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'pending',
      ),
    ];
  }

  static List<BroadcastAnnouncement> _getSeedBroadcasts() {
    return [
      BroadcastAnnouncement(
        id: 'bc_1',
        title: '🔥 Question of the Day: Consistent Hashing',
        body: 'Brush up on distributed caching architectures today and earn 50 bonus XP!',
        tag: 'Question of the Day',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isPinned: true,
      ),
      BroadcastAnnouncement(
        id: 'bc_2',
        title: '🚀 New Company Pack: FinTech Technicals',
        body: '30+ high-frequency questions on ACID properties, B+ Trees, and low-latency trading algorithms.',
        tag: 'Feature Update',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isPinned: false,
      ),
    ];
  }
}
