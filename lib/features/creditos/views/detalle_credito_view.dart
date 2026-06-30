import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/core_api_client.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/app_info_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/status_badge.dart';

class DetalleCreditoView extends ConsumerStatefulWidget {
  const DetalleCreditoView({super.key, required this.creditoId});

  final String creditoId;

  @override
  ConsumerState<DetalleCreditoView> createState() => _DetalleCreditoViewState();
}

class _DetalleCreditoViewState extends ConsumerState<DetalleCreditoView> {
  bool _loading = true;
  bool _paying = false;
  Map<String, dynamic>? _credito;
  List<Map<String, dynamic>> _cuotas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      final credito = await supabase
          .from('creditos')
          .select()
          .eq('id', widget.creditoId)
          .maybeSingle();

      final cuotas = await supabase
          .from('cronograma_credito')
          .select()
          .eq('credito_id', widget.creditoId)
          .order('numero_cuota');

      if (!mounted) return;
      setState(() {
        _credito = credito;
        _cuotas = List<Map<String, dynamic>>.from(cuotas as List);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar crédito: $e')),
      );
    }
  }

  Future<void> _refreshMovimientos(String clienteId) async {
    await supabase
        .from('movimientos')
        .select()
        .eq('cliente_id', clienteId)
        .order('fecha_movimiento', ascending: false);
  }

  Future<void> _pagarCuotaDemo() async {
    final cliente = ref.read(clienteSessionProvider);
    if (cliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión de cliente no disponible')),
      );
      return;
    }

    final clienteId = cliente['id'].toString();
    final creditoId = widget.creditoId;

    setState(() => _paying = true);

    try {
      final message = await CoreApiClient.pagarCuotaDemo(creditoId);

      await _loadData();
      await _refreshMovimientos(clienteId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on CoreApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      debugPrint('Error al pagar cuota demo via Core: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? '—')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle crédito'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadData,
          ),
        ],
      ),
      body: _loading
          ? const LoadingView()
          : _credito == null
              ? const EmptyState(
                  message: 'Crédito no encontrado',
                  icon: Icons.error_outline,
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            AppInfoCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _credito!['producto']?.toString() ??
                                        'Crédito',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  const Divider(height: 24),
                                  _infoRow(
                                    'Monto desembolsado',
                                    FormatUtils.currency(
                                      (_credito!['monto_desembolsado']
                                              as num?) ??
                                          0,
                                    ),
                                  ),
                                  _infoRow(
                                    'Saldo actual',
                                    FormatUtils.currency(
                                      (_credito!['saldo_actual'] as num?) ?? 0,
                                    ),
                                  ),
                                  _infoRow(
                                    'Plazo',
                                    '${_credito!['plazo_meses'] ?? '—'} meses',
                                  ),
                                  _infoRow(
                                    'Cuotas',
                                    '${_credito!['cuotas_pagadas'] ?? 0} / ${_credito!['cuotas_total'] ?? 0}',
                                  ),
                                  _infoRow('Estado', _credito!['estado']),
                                  _infoRow(
                                    'Días mora',
                                    _credito!['dias_mora'] ?? 0,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cronograma',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            if (_cuotas.isEmpty)
                              const AppInfoCard(
                                child: Text('Sin cuotas registradas'),
                              )
                            else
                              ..._cuotas.map(
                                (cuota) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AppInfoCard(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Cuota ${cuota['numero_cuota'] ?? '—'}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Vence: ${FormatUtils.formatDate(cuota['fecha_vencimiento'])}',
                                              ),
                                              Text(
                                                'Cuota: ${FormatUtils.currency((cuota['cuota'] as num?) ?? 0)}',
                                              ),
                                              Text(
                                                'Pagado: ${FormatUtils.currency((cuota['monto_pagado'] as num?) ?? 0)}',
                                              ),
                                              Text(
                                                'Días mora: ${cuota['dias_mora'] ?? 0}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.darkText
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        StatusBadge.cuota(
                                          cuota['estado']?.toString(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _paying
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton.icon(
                                onPressed: _pagarCuotaDemo,
                                icon: const Icon(Icons.payment),
                                label: const Text('Pagar cuota demo'),
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
