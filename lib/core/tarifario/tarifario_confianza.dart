/// Tarifario académico — Crédito Empresarial Microempresa (Banco Andino).
library;

class ProductoTarifario {
  const ProductoTarifario({
    required this.codigo,
    required this.nombre,
    required this.teaMaxima,
    required this.teaReferencial,
    required this.montoMin,
    required this.montoMax,
    required this.plazoMinMeses,
    required this.plazoMaxMeses,
    this.nota = '',
  });

  final String codigo;
  final String nombre;
  final double teaMaxima;
  final double teaReferencial;
  final double montoMin;
  final double montoMax;
  final int plazoMinMeses;
  final int plazoMaxMeses;
  final String nota;
}

abstract final class TarifarioConfianza {
  static const tarifarioVersion = 'BANCO-ANDINO-MICRO';
  static const productoDefaultCodigo = 'credito_microempresa';
  static const teaConDesgravamen = 40.92;
  static const teaSinDesgravamen = 43.92;

  static const Map<String, ProductoTarifario> productos = {
    'credito_microempresa': ProductoTarifario(
      codigo: 'credito_microempresa',
      nombre: 'Crédito Empresarial Microempresa',
      teaMaxima: 43.92,
      teaReferencial: 43.92,
      montoMin: 1000,
      montoMax: 20000,
      plazoMinMeses: 3,
      plazoMaxMeses: 36,
      nota: 'TEA 43.92% sin desgravamen / 40.92% con desgravamen.',
    ),
  };

  static const Map<String, String> tipoNegocioAProducto = {
    'microempresa': 'credito_microempresa',
    'pyme': 'credito_microempresa',
    'negocio': 'credito_microempresa',
  };

  static ProductoTarifario resolverProducto({String? tipoNegocio, String? codigo}) {
    if (codigo != null && productos.containsKey(codigo)) {
      return productos[codigo]!;
    }
    if (tipoNegocio != null && tipoNegocio.trim().isNotEmpty) {
      final key = tipoNegocio.trim().toLowerCase().replaceAll(' ', '_');
      final productoCodigo = tipoNegocioAProducto[key] ?? productoDefaultCodigo;
      return productos[productoCodigo]!;
    }
    return productos[productoDefaultCodigo]!;
  }

  static List<String> validarSolicitud({
    required double monto,
    required int plazoMeses,
    String? tipoNegocio,
    String? codigoProducto,
  }) {
    final producto = resolverProducto(
      tipoNegocio: tipoNegocio,
      codigo: codigoProducto,
    );
    final errores = <String>[];

    if (monto < producto.montoMin) {
      errores.add('Monto mínimo: S/ ${producto.montoMin.toStringAsFixed(2)}');
    }
    if (monto > producto.montoMax) {
      errores.add('Monto máximo: S/ ${producto.montoMax.toStringAsFixed(2)}');
    }
    if (plazoMeses < producto.plazoMinMeses) {
      errores.add('Plazo mínimo: ${producto.plazoMinMeses} meses');
    }
    if (plazoMeses > producto.plazoMaxMeses) {
      errores.add('Plazo máximo: ${producto.plazoMaxMeses} meses');
    }

    return errores;
  }
}
