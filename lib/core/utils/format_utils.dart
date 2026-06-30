import 'package:intl/intl.dart';

abstract final class FormatUtils {
  static final _currency = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ');

  static String currency(num value) => _currency.format(value);

  static String fullName(Map<String, dynamic> row) {
    final nombre = row['nombre']?.toString();
    if (nombre != null && nombre.isNotEmpty) return nombre;

    final nombres = row['nombres']?.toString() ?? '';
    final apellidos = row['apellidos']?.toString() ?? '';
    final combined = '$nombres $apellidos'.trim();
    if (combined.isNotEmpty) return combined;

    return row['numero_documento']?.toString() ?? 'Cliente';
  }

  static String formatDate(dynamic value) {
    if (value == null) return '—';
    try {
      final date = DateTime.parse(value.toString());
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return value.toString();
    }
  }

  static String formatDateTime(dynamic value) {
    if (value == null) return '—';
    try {
      final date = DateTime.parse(value.toString());
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return value.toString();
    }
  }
}
