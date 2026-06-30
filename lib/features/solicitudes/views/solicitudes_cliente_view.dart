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

class SolicitudesClienteView extends ConsumerStatefulWidget {
  const SolicitudesClienteView({super.key});

  @override
  ConsumerState<SolicitudesClienteView> createState() =>
      _SolicitudesClienteViewState();
}

class _SolicitudesClienteViewState extends ConsumerState<SolicitudesClienteView> {
  bool _loading = true;
  List<Map<String, dynamic>> _solicitudes = [];

  @override
  void initState() {
    super.initState();
    _loadSolicitudes();
  }

  Future<void> _loadSolicitudes() async {
    setState(() => _loading = true);

    try {
      final cliente = ref.read(clienteSessionProvider);
      if (cliente == null) {
        throw Exception('Sesión de cliente no disponible');
      }

      final data = await supabase
          .from('solicitudes_credito')
          .select()
          .eq('cliente_id', cliente['id'])
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _solicitudes = List<Map<String, dynamic>>.from(data as List);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar solicitudes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Solicitudes')),
      body: _loading
          ? const LoadingView()
          : _solicitudes.isEmpty
              ? const EmptyState(
                  message: 'No tienes solicitudes registradas',
                  icon: Icons.assignment_outlined,
                )
              : RefreshIndicator(
                  onRefresh: _loadSolicitudes,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _solicitudes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final s = _solicitudes[index];

                      return AppInfoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    s['numero_expediente']?.toString() ?? '—',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                StatusBadge.solicitud(s['estado']?.toString()),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Monto: ${FormatUtils.currency((s['monto_solicitado'] as num?) ?? 0)}',
                            ),
                            Text('Plazo: ${s['plazo_meses'] ?? '—'} meses'),
                            Text(
                              'Cuota est.: ${FormatUtils.currency((s['cuota_estimada'] as num?) ?? 0)}',
                            ),
                            Text(
                              'Fecha: ${FormatUtils.formatDateTime(s['created_at'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkText.withValues(alpha: 0.6),
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
