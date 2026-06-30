import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.darkText.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
