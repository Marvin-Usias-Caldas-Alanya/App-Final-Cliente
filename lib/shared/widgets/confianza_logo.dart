import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Logo oficial de la app con fallback seguro.
class ConfianzaLogo extends StatelessWidget {
  const ConfianzaLogo({
    super.key,
    this.height = 90,
    this.maxWidth,
    this.alignment = Alignment.center,
  });

  final double height;
  final double? maxWidth;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      AppConstants.logoAssetPath,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Text(
          'Financiera Confianza',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        );
      },
    );

    return Align(
      alignment: alignment,
      child: maxWidth != null
          ? ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth!),
              child: image,
            )
          : image,
    );
  }
}
