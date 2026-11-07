import 'package:flutter/foundation.dart';
import '../models/flagged_report_model.dart';
import '../services/admin_storage_service.dart';

class AdminFlaggedProvider extends ChangeNotifier {
  List<FlaggedReport> _reports = [];

  List<FlaggedReport> get reports => _reports;
  int get pendingCount => _reports.where((r) => r.status == 'pending').length;

  AdminFlaggedProvider() {
    _init();
  }

  Future<void> _init() async {
    _reports = await AdminStorageService.loadFlaggedReports();
    notifyListeners();
  }

  Future<void> resolveReport(String id) async {
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _reports[idx].status = 'resolved';
      await AdminStorageService.saveFlaggedReports(_reports);
      notifyListeners();
    }
  }

  Future<void> reopenReport(String id) async {
    final idx = _reports.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _reports[idx].status = 'pending';
      await AdminStorageService.saveFlaggedReports(_reports);
      notifyListeners();
    }
  }

  Future<void> deleteReport(String id) async {
    _reports.removeWhere((r) => r.id == id);
    await AdminStorageService.saveFlaggedReports(_reports);
    notifyListeners();
  }
}
