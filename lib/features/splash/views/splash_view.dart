import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/confianza_logo.dart';
import '../viewmodels/splash_viewmodel.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashViewModelProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(splashViewModelProvider, (previous, next) {
      if (next == SplashNavigationTarget.auth && context.mounted) {
        context.go(AppRoute.auth.path);
      }
      if (next == SplashNavigationTarget.home && context.mounted) {
        context.go(AppRoute.home.path);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const ConfianzaLogo(),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
