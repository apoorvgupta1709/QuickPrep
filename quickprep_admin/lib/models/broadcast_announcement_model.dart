class BroadcastAnnouncement {
  final String id;
  final String title;
  final String body;
  final String tag; // 'Question of the Day', 'Feature Update', 'Promo'
  final DateTime createdAt;
  final bool isPinned;

  BroadcastAnnouncement({
    required this.id,
    required this.title,
    required this.body,
    required this.tag,
    required this.createdAt,
    this.isPinned = false,
  });

  factory BroadcastAnnouncement.fromJson(Map<String, dynamic> json) {
    return BroadcastAnnouncement(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      tag: json['tag'] as String? ?? 'Question of the Day',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      isPinned: json['is_pinned'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'tag': tag,
      'created_at': createdAt.toIso8601String(),
      'is_pinned': isPinned,
    };
  }
}
