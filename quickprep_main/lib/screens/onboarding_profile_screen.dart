import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile_model.dart';
import '../providers/user_profile_provider.dart';
import '../core/theme.dart';
import 'home_screen.dart';

class OnboardingProfileScreen extends StatefulWidget {
  final bool isEditingFromSettings;

  const OnboardingProfileScreen({
    super.key,
    this.isEditingFromSettings = false,
  });

  @override
  State<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends State<OnboardingProfileScreen> {
  late String _selectedProfession;
  late String _selectedExperience;
  late String _selectedCompanyTier;
  late int _selectedDailyGoal;

  final Map<String, IconData> _roleIcons = {
    CareerRoles.frontend: Icons.laptop_chromebook,
    CareerRoles.backend: Icons.dns_outlined,
    CareerRoles.fullstack: Icons.layers_outlined,
    CareerRoles.mobile: Icons.smartphone,
    CareerRoles.devops: Icons.cloud_queue,
    CareerRoles.dataAi: Icons.psychology_outlined,
    CareerRoles.fresher: Icons.school_outlined,
    CareerRoles.architect: Icons.account_tree_outlined,
  };

  @override
  void initState() {
    super.initState();
    final profile =
        Provider.of<UserProfileProvider>(context, listen: false).profile;
    _selectedProfession = profile.profession;
    _selectedExperience = profile.experienceLevel;
    _selectedCompanyTier = profile.targetCompanyTier;
    _selectedDailyGoal = profile.dailyGoal;
  }

  void _submitProfile() async {
    final profileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);

    await profileProvider.saveProfile(
      UserProfile(
        profession: _selectedProfession,
        experienceLevel: _selectedExperience,
        targetCompanyTier: _selectedCompanyTier,
        dailyGoal: _selectedDailyGoal,
        isCompleted: true,
      ),
    );

    if (!mounted) return;

    if (widget.isEditingFromSettings) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Career Track updated to $_selectedProfession! 🎯'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditingFromSettings
            ? 'Career Track Settings'
            : 'Personalize Your Prep'),
        automaticallyImplyLeading: widget.isEditingFromSettings,
        actions: [
          if (!widget.isEditingFromSettings)
            TextButton(
              onPressed: _submitProfile,
              child: const Text('Skip', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(50),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Tailored Interview Track',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tell us your target profession and experience level so we prioritize the exact questions and topics asked in your upcoming interviews.',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Question 1: Target Profession / Role
              Row(
                children: const [
                  Icon(Icons.work_outline, color: AppTheme.primaryLight, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '1. What is your Target Role?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CareerRoles.all.map((role) {
                  final isSelected = _selectedProfession == role;
                  return ChoiceChip(
                    avatar: Icon(
                      _roleIcons[role] ?? Icons.code,
                      size: 16,
                      color: isSelected ? Colors.white : AppTheme.primaryLight,
                    ),
                    label: Text(role),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.lightTextPrimary),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedProfession = role);
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Question 2: Experience Level
              Row(
                children: const [
                  Icon(Icons.timeline, color: AppTheme.secondary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '2. Experience Level',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Column(
                children: ExperienceLevels.all.map((level) {
                  final isSelected = _selectedExperience == level;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Material(
                      color: isSelected
                          ? AppTheme.primary.withAlpha(25)
                          : (isDark
                              ? AppTheme.darkSurface
                              : Colors.grey.shade100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark ? Colors.white12 : Colors.black12),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: RadioListTile<String>(
                        title: Text(
                          level,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? AppTheme.primaryLight : null,
                          ),
                        ),
                        value: level,
                        groupValue: _selectedExperience,
                        activeColor: AppTheme.primary,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedExperience = val);
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Question 3: Target Company Focus
              Row(
                children: const [
                  Icon(Icons.business_outlined, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '3. Target Company Tier',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TargetCompanyTiers.allTiers.map((tier) {
                  final isSelected = _selectedCompanyTier == tier;
                  return ChoiceChip(
                    label: Text(tier),
                    selected: isSelected,
                    selectedColor: Colors.deepOrangeAccent,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.lightTextPrimary),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCompanyTier = tier);
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Question 4: Daily Flashcard Goal
              Row(
                children: const [
                  Icon(Icons.alarm, color: Colors.cyan, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '4. Daily Practice Goal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [5, 10, 20].map((goal) {
                  final isSelected = _selectedDailyGoal == goal;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDailyGoal = goal),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : (isDark
                                  ? AppTheme.darkSurface
                                  : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : (isDark ? Colors.white12 : Colors.black12),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$goal Cards',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal == 5
                                  ? 'Casual'
                                  : (goal == 10 ? 'Standard' : 'Intensive'),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? Colors.white70
                                    : (isDark
                                        ? AppTheme.darkTextSecondary
                                        : AppTheme.lightTextSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.rocket_launch, color: Colors.white),
                  label: Text(
                    widget.isEditingFromSettings
                        ? 'Save Changes'
                        : 'Launch Personalized Track 🚀',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
