class Category {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int questionCount;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.questionCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? 'code',
      description: json['description'] as String? ?? '',
      questionCount: json['question_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'question_count': questionCount,
    };
  }
}
