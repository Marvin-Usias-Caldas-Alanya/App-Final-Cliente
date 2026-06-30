import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'confianza_logo.dart';

class AppGradientHeader extends StatelessWidget {
  const AppGradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showLogo = false,
    this.height = 160,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showLogo;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, AppColors.secondaryBlue, AppColors.aqua],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showLogo) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const ConfianzaLogo(
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
