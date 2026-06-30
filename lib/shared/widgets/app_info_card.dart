import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_design.dart';

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    if (onTap == null) {
      return Container(
        decoration: AppDesign.cardDecoration,
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDesign.cardRadius,
        child: Ink(
          decoration: AppDesign.cardDecoration,
          child: content,
        ),
      ),
    );
  }
}

class AppAmountCard extends StatelessWidget {
  const AppAmountCard({
    super.key,
    required this.label,
    required this.amount,
    this.subtitle,
    this.icon,
    this.accentColor = AppColors.primaryBlue,
  });

  final String label;
  final String amount;
  final String? subtitle;
  final IconData? icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDesign.tintedCard(accentColor),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor),
            ),
          if (icon != null) const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.darkText.withValues(alpha: 0.65),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppColors.darkText.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
