import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_provider.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/app_info_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/status_badge.dart';

class MovimientosView extends ConsumerStatefulWidget {
  const MovimientosView({super.key});

  @override
  ConsumerState<MovimientosView> createState() => _MovimientosViewState();
}

class _MovimientosViewState extends ConsumerState<MovimientosView> {
  bool _loading = true;
  List<Map<String, dynamic>> _movimientos = [];

  @override
  void initState() {
    super.initState();
    _loadMovimientos();
  }

  Future<void> _loadMovimientos() async {
    setState(() => _loading = true);

    try {
      final cliente = ref.read(clienteSessionProvider);
      if (cliente == null) {
        throw Exception('Sesión de cliente no disponible');
      }

      final data = await supabase
          .from('movimientos')
          .select()
          .eq('cliente_id', cliente['id'])
          .order('fecha_movimiento', ascending: false);

      if (!mounted) return;
      setState(() {
        _movimientos = List<Map<String, dynamic>>.from(data as List);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar movimientos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Movimientos')),
      body: _loading
          ? const LoadingView()
          : _movimientos.isEmpty
              ? const EmptyState(
                  message: 'No hay movimientos registrados',
                  icon: Icons.receipt_long_outlined,
                )
              : RefreshIndicator(
                  onRefresh: _loadMovimientos,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _movimientos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final m = _movimientos[index];
                      final tipo = m['tipo']?.toString();
                      final color = movimientoColor(tipo);

                      return AppInfoCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                movimientoIcon(tipo),
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['descripcion']?.toString() ?? '—',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    m['fecha_movimiento'] == null
                                        ? 'Sin fecha'
                                        : FormatUtils.formatDateTime(
                                            m['fecha_movimiento'],
                                          ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.darkText
                                          .withValues(alpha: 0.55),
                                    ),
                                  ),
                                  Text(
                                    tipo ?? '—',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              FormatUtils.currency((m['monto'] as num?) ?? 0),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
