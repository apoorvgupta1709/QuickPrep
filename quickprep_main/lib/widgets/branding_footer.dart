import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class BrandingFooter extends StatelessWidget {
  final bool isSubtle;

  const BrandingFooter({super.key, this.isSubtle = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSubtle
                ? Colors.transparent
                : (isDark
                    ? AppTheme.darkSurfaceElevated.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(20),
            border: isSubtle
                ? null
                : Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withOpacity(0.06),
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.code,
                size: 14,
                color: AppTheme.primaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                AppConstants.brandingFooter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
