import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppDesign {
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(18));

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: cardRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration tintedCard(Color color) => BoxDecoration(
        color: AppColors.surface,
        borderRadius: cardRadius,
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );
}
