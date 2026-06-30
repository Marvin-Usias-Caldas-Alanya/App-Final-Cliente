import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/app_action_card.dart';
import '../../../shared/widgets/app_gradient_header.dart';
import '../../../shared/widgets/app_info_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cliente = ref.watch(clienteSessionProvider);
    final nombre = cliente != null ? FormatUtils.fullName(cliente) : 'Cliente';
    final homeAsync = ref.watch(clienteHomeDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: homeAsync.maybeWhen(
        data: (data) => data.proximoCreditoId != null
            ? FloatingActionButton.extended(
                onPressed: () => context.push(
                  AppRoute.detalleCredito.path.replaceFirst(
                    ':creditoId',
                    data.proximoCreditoId!,
                  ),
                ),
                icon: const Icon(Icons.payment),
                label: const Text('Pagar cuota'),
              )
            : null,
        orElse: () => null,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(clienteHomeDataProvider);
          await ref.read(clienteHomeDataProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AppGradientHeader(
                showLogo: true,
                title: 'Hola, $nombre',
                subtitle: 'Tu banca móvil Confianza',
                trailing: IconButton(
                  onPressed: () =>
                      ref.read(authViewModelProvider.notifier).signOut(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 88),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  homeAsync.when(
                    loading: () => const AppInfoCard(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    error: (_, __) => AppAmountCard(
                      label: 'Deuda total',
                      amount: FormatUtils.currency(0),
                      subtitle: 'No se pudo cargar el resumen',
                      icon: Icons.account_balance_wallet_outlined,
                      accentColor: AppColors.primaryBlue,
                    ),
                    data: (data) => Column(
                      children: [
                        AppAmountCard(
                          label: 'Deuda total',
                          amount: FormatUtils.currency(data.deudaTotal),
                          subtitle: 'Saldo consolidado de tus créditos',
                          icon: Icons.account_balance_wallet_outlined,
                          accentColor: AppColors.primaryBlue,
                        ),
                        if (data.proximaCuota != null) ...[
                          const SizedBox(height: 12),
                          AppInfoCard(
                            onTap: data.proximoCreditoId != null
                                ? () => context.push(
                                      AppRoute.detalleCredito.path.replaceFirst(
                                        ':creditoId',
                                        data.proximoCreditoId!,
                                      ),
                                    )
                                : null,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.orange
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.event_outlined,
                                    color: AppColors.orange,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Próxima cuota',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        FormatUtils.currency(
                                          (data.proximaCuota!['cuota']
                                                  as num?) ??
                                              0,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Vence: ${FormatUtils.formatDate(data.proximaCuota!['fecha_vencimiento'])}',
                                        style: TextStyle(
                                          color: AppColors.darkText
                                              .withValues(alpha: 0.6),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge.cuota(
                                  data.proximaCuota!['estado']?.toString(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Accesos rápidos',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.05,
                    children: [
                      AppActionCard(
                        title: 'Mis créditos',
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.aqua,
                        onTap: () => context.push(AppRoute.creditos.path),
                      ),
                      AppActionCard(
                        title: 'Solicitudes',
                        icon: Icons.assignment_outlined,
                        color: AppColors.secondaryBlue,
                        onTap: () => context.push(AppRoute.solicitudes.path),
                      ),
                      AppActionCard(
                        title: 'Movimientos',
                        icon: Icons.receipt_long_outlined,
                        color: AppColors.green,
                        onTap: () => context.push(AppRoute.movimientos.path),
                      ),
                      AppActionCard(
                        title: 'Perfil',
                        icon: Icons.person_outline,
                        color: AppColors.orange,
                        onTap: () => context.push(AppRoute.perfil.path),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Últimas operaciones',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  homeAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (data) => data.ultimosMovimientos.isEmpty
                        ? AppInfoCard(
                            child: Text(
                              'Sin operaciones recientes',
                              style: TextStyle(
                                color:
                                    AppColors.darkText.withValues(alpha: 0.6),
                              ),
                            ),
                          )
                        : Column(
                            children: data.ultimosMovimientos.map((m) {
                              final tipo = m['tipo']?.toString();
                              final color = movimientoColor(tipo);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AppInfoCard(
                                  onTap: () =>
                                      context.push(AppRoute.movimientos.path),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          movimientoIcon(tipo),
                                          color: color,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              m['descripcion']?.toString() ??
                                                  '—',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
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
                                          ],
                                        ),
                                      ),
                                      Text(
                                        FormatUtils.currency(
                                          (m['monto'] as num?) ?? 0,
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
