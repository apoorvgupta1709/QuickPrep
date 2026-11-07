import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/broadcast_announcement_model.dart';
import '../services/admin_storage_service.dart';

class AdminBroadcastProvider extends ChangeNotifier {
  List<BroadcastAnnouncement> _broadcasts = [];
  static const _uuid = Uuid();

  List<BroadcastAnnouncement> get broadcasts => _broadcasts;

  AdminBroadcastProvider() {
    _init();
  }

  Future<void> _init() async {
    _broadcasts = await AdminStorageService.loadBroadcasts();
    notifyListeners();
  }

  Future<void> createBroadcast({
    required String title,
    required String body,
    required String tag,
    required bool isPinned,
  }) async {
    final newBc = BroadcastAnnouncement(
      id: 'bc_${_uuid.v4().substring(0, 8)}',
      title: title,
      body: body,
      tag: tag,
      createdAt: DateTime.now(),
      isPinned: isPinned,
    );

    _broadcasts.insert(0, newBc);
    await AdminStorageService.saveBroadcasts(_broadcasts);
    notifyListeners();
  }

  Future<void> deleteBroadcast(String id) async {
    _broadcasts.removeWhere((b) => b.id == id);
    await AdminStorageService.saveBroadcasts(_broadcasts);
    notifyListeners();
  }
}
