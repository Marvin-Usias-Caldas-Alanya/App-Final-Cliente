import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../../../core/supabase/supabase_client.dart';

class ClienteHomeData {
  const ClienteHomeData({
    this.deudaTotal = 0,
    this.proximaCuota,
    this.proximoCreditoId,
    this.ultimosMovimientos = const [],
  });

  final num deudaTotal;
  final Map<String, dynamic>? proximaCuota;
  final String? proximoCreditoId;
  final List<Map<String, dynamic>> ultimosMovimientos;
}

final clienteHomeDataProvider =
    FutureProvider.autoDispose<ClienteHomeData>((ref) async {
  final cliente = ref.watch(clienteSessionProvider);
  if (cliente == null) {
    throw Exception('Sesión de cliente no disponible');
  }

  final clienteId = cliente['id'];

  final creditos = await supabase
      .from('creditos')
      .select('id, saldo_actual')
      .eq('cliente_id', clienteId);

  final creditoRows = List<Map<String, dynamic>>.from(creditos as List);
  final creditoIds = creditoRows.map((c) => c['id']).toList();

  num deudaTotal = 0;
  for (final c in creditoRows) {
    deudaTotal += (c['saldo_actual'] as num?) ?? 0;
  }

  Map<String, dynamic>? proximaCuota;
  String? proximoCreditoId;

  if (creditoIds.isNotEmpty) {
    final pendientes = await supabase
        .from('cronograma_credito')
        .select()
        .inFilter('credito_id', creditoIds)
        .neq('estado', 'pagado')
        .order('fecha_vencimiento')
        .limit(1);

    final cuotaRows = List<Map<String, dynamic>>.from(pendientes as List);
    if (cuotaRows.isNotEmpty) {
      proximaCuota = cuotaRows.first;
      proximoCreditoId = proximaCuota['credito_id']?.toString();
    }
  }

  final movimientos = await supabase
      .from('movimientos')
      .select()
      .eq('cliente_id', clienteId)
      .order('fecha_movimiento', ascending: false)
      .limit(3);

  return ClienteHomeData(
    deudaTotal: deudaTotal,
    proximaCuota: proximaCuota,
    proximoCreditoId: proximoCreditoId,
    ultimosMovimientos:
        List<Map<String, dynamic>>.from(movimientos as List),
  );
});
