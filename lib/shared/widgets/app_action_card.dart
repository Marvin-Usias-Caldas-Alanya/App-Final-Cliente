import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_design.dart';

class AppActionCard extends StatelessWidget {
  const AppActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppDesign.cardRadius,
      elevation: 0,
      shadowColor: AppColors.primaryBlue.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDesign.cardRadius,
        child: Ink(
          decoration: AppDesign.cardDecoration,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                  fontSize: 13,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.darkText.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
