import '../../../core/supabase/supabase_client.dart';

/// Resuelve email de autenticación a partir del DNI en tabla clientes.
Future<String?> resolveEmailFromDni(String dni) async {
  final normalized = dni.trim();
  if (normalized.length < 8) return null;

  final legacy = _legacyEmail(normalized);
  if (legacy != null) return legacy;

  final row = await supabase
      .from('clientes')
      .select('numero_documento')
      .eq('numero_documento', normalized)
      .maybeSingle();

  if (row != null) {
    return '$normalized@confianza.local';
  }

  return null;
}

String? _legacyEmail(String dni) {
  switch (dni) {
    case '45678912':
      return 'cliente001@confianza.local';
    case '71234567':
      return 'cliente002@confianza.local';
    default:
      return null;
  }
}
