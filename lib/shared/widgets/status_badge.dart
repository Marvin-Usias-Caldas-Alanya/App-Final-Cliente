import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  factory StatusBadge.solicitud(String? estado) {
    final normalized = estado?.toLowerCase() ?? '';
    Color color;
    switch (normalized) {
      case 'enviado':
        color = AppColors.secondaryBlue;
      case 'recibido_comite':
        color = Colors.purple;
      case 'aprobado':
        color = AppColors.green;
      case 'rechazado':
        color = AppColors.red;
      case 'desembolsado':
        color = AppColors.orange;
      default:
        color = AppColors.primaryBlue;
    }
    return StatusBadge(
      label: normalized.replaceAll('_', ' ').isEmpty
          ? '—'
          : normalized.replaceAll('_', ' '),
      color: color,
    );
  }

  factory StatusBadge.cuota(String? estado) {
    final normalized = estado?.toLowerCase() ?? '';
    Color color;
    switch (normalized) {
      case 'pagado':
        color = AppColors.green;
      case 'vencido':
        color = AppColors.red;
      case 'pendiente':
      default:
        color = AppColors.orange;
    }
    return StatusBadge(
      label: normalized.isEmpty ? 'pendiente' : normalized,
      color: color,
    );
  }

  factory StatusBadge.visita(String? estado) {
    final normalized = estado?.toLowerCase() ?? '';
    Color color;
    switch (normalized) {
      case 'visitado':
      case 'completado':
        color = AppColors.green;
      case 'pendiente':
        color = AppColors.orange;
      default:
        color = AppColors.secondaryBlue;
    }
    return StatusBadge(
      label: normalized.isEmpty ? '—' : normalized,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

IconData movimientoIcon(String? tipo) {
  switch (tipo?.toLowerCase()) {
    case 'pago_credito':
      return Icons.payments_outlined;
    case 'desembolso':
      return Icons.account_balance_outlined;
    case 'transferencia':
      return Icons.swap_horiz_rounded;
    case 'deposito':
      return Icons.south_west_rounded;
    case 'retiro':
      return Icons.north_east_rounded;
    default:
      return Icons.receipt_long_outlined;
  }
}

Color movimientoColor(String? tipo) {
  switch (tipo?.toLowerCase()) {
    case 'pago_credito':
      return AppColors.green;
    case 'desembolso':
      return AppColors.secondaryBlue;
    case 'transferencia':
      return AppColors.aqua;
    case 'deposito':
      return AppColors.green;
    case 'retiro':
      return AppColors.orange;
    default:
      return AppColors.primaryBlue;
  }
}
