import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/app_info_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/status_badge.dart';

class MisCreditosView extends ConsumerStatefulWidget {
  const MisCreditosView({super.key});

  @override
  ConsumerState<MisCreditosView> createState() => _MisCreditosViewState();
}

class _MisCreditosViewState extends ConsumerState<MisCreditosView> {
  bool _loading = true;
  List<Map<String, dynamic>> _creditos = [];

  @override
  void initState() {
    super.initState();
    _loadCreditos();
  }

  Future<void> _loadCreditos() async {
    setState(() => _loading = true);

    try {
      final cliente = ref.read(clienteSessionProvider);
      if (cliente == null) {
        throw Exception('Sesión de cliente no disponible');
      }

      final data = await supabase
          .from('creditos')
          .select()
          .eq('cliente_id', cliente['id']);

      if (!mounted) return;
      setState(() {
        _creditos = List<Map<String, dynamic>>.from(data as List);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar créditos: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mis créditos')),
      body: _loading
          ? const LoadingView()
          : _creditos.isEmpty
              ? const EmptyState(
                  message: 'No tienes créditos registrados',
                  icon: Icons.account_balance_wallet_outlined,
                )
              : RefreshIndicator(
                  onRefresh: _loadCreditos,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _creditos.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final c = _creditos[index];
                      final cuotasPagadas = c['cuotas_pagadas'] ?? 0;
                      final cuotasTotal = c['cuotas_total'] ?? 0;
                      final progress = cuotasTotal == 0
                          ? 0.0
                          : cuotasPagadas / cuotasTotal;

                      return AppInfoCard(
                        onTap: () {
                          final id = c['id']?.toString();
                          if (id != null) {
                            context.push(
                              AppRoute.detalleCredito.path.replaceFirst(
                                ':creditoId',
                                id,
                              ),
                            );
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    c['producto']?.toString() ?? 'Crédito',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                StatusBadge(
                                  label: c['estado']?.toString() ?? '—',
                                  color: AppColors.secondaryBlue,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _MiniStat(
                                    label: 'Saldo',
                                    value: FormatUtils.currency(
                                      (c['saldo_actual'] as num?) ?? 0,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _MiniStat(
                                    label: 'Desembolso',
                                    value: FormatUtils.currency(
                                      (c['monto_desembolsado'] as num?) ?? 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: AppColors.background,
                                color: AppColors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cuotas $cuotasPagadas/$cuotasTotal · Mora: ${c['dias_mora'] ?? 0} días',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    AppColors.darkText.withValues(alpha: 0.6),
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.darkText.withValues(alpha: 0.55),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
