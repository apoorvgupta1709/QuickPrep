class UserProfile {
  final String profession;
  final String experienceLevel;
  final String targetCompanyTier;
  final int dailyGoal;
  final bool isCompleted;

  const UserProfile({
    this.profession = 'Full-Stack Developer',
    this.experienceLevel = 'Mid-Level (2-4 yrs)',
    this.targetCompanyTier = 'All Companies',
    this.dailyGoal = 10,
    this.isCompleted = false,
  });

  UserProfile copyWith({
    String? profession,
    String? experienceLevel,
    String? targetCompanyTier,
    int? dailyGoal,
    bool? isCompleted,
  }) {
    return UserProfile(
      profession: profession ?? this.profession,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      targetCompanyTier: targetCompanyTier ?? this.targetCompanyTier,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'profession': profession,
        'experienceLevel': experienceLevel,
        'targetCompanyTier': targetCompanyTier,
        'dailyGoal': dailyGoal,
        'isCompleted': isCompleted,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        profession: json['profession'] as String? ?? 'Full-Stack Developer',
        experienceLevel:
            json['experienceLevel'] as String? ?? 'Mid-Level (2-4 yrs)',
        targetCompanyTier:
            json['targetCompanyTier'] as String? ?? 'All Companies',
        dailyGoal: json['dailyGoal'] as int? ?? 10,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class CareerRoles {
  static const String frontend = 'Frontend Developer';
  static const String backend = 'Backend Developer';
  static const String fullstack = 'Full-Stack Developer';
  static const String mobile = 'Mobile App Developer';
  static const String devops = 'DevOps & Cloud Engineer';
  static const String dataAi = 'Data & AI Engineer';
  static const String fresher = 'College Fresher / Student';
  static const String architect = 'System Architect & Tech Lead';

  static const List<String> all = [
    frontend,
    backend,
    fullstack,
    mobile,
    devops,
    dataAi,
    fresher,
    architect,
  ];
}

class ExperienceLevels {
  static const String fresher = 'Fresher / Student (0-1 yr)';
  static const String junior = 'Junior Associate (1-2 yrs)';
  static const String mid = 'Mid-Level (2-4 yrs)';
  static const String senior = 'Senior / Staff (5+ yrs)';

  static const List<String> all = [
    fresher,
    junior,
    mid,
    senior,
  ];
}

class TargetCompanyTiers {
  static const String all = 'All Companies';
  static const String faang = 'FAANG & Top Tech (Google, Meta, Apple)';
  static const String startups = 'High-Growth Tech Startups';
  static const String fintech = 'FinTech & Banking (Stripe, Razorpay)';
  static const String enterprise = 'Global Enterprise (MNCs)';

  static const List<String> allTiers = [
    all,
    faang,
    startups,
    fintech,
    enterprise,
  ];
}
