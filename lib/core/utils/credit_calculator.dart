import 'dart:math' as math;

import '../tarifario/tarifario_confianza.dart';

abstract final class CreditCalculator {
  static double get defaultTea =>
      TarifarioConfianza.resolverProducto().teaReferencial;

  static double cuotaFrancesa({
    required double monto,
    required int plazoMeses,
    double? teaPercent,
  }) {
    final tea = teaPercent ?? defaultTea;
    if (monto <= 0 || plazoMeses <= 0) return 0;

    final teaDecimal = tea / 100;
    final i = math.pow(1 + teaDecimal, 1 / 12) - 1;
    final factor = math.pow(1 + i, plazoMeses);
    if (factor == 1) return monto / plazoMeses;

    return monto * i * factor / (factor - 1);
  }
}
