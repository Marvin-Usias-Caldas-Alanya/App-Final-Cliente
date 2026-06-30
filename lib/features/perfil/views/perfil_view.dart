import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/widgets/app_info_card.dart';
import '../../../shared/widgets/confianza_logo.dart';

class PerfilView extends ConsumerWidget {
  const PerfilView({super.key});

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkText.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '—',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cliente = ref.watch(clienteSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Perfil')),
      body: cliente == null
          ? const Center(child: Text('Sesión no disponible'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppInfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  AppColors.aqua.withValues(alpha: 0.15),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.secondaryBlue,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                FormatUtils.fullName(cliente),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 28),
                        _infoRow('Nombres', cliente['nombres']),
                        _infoRow('Apellidos', cliente['apellidos']),
                        _infoRow('Documento', cliente['numero_documento']),
                        _infoRow('Teléfono', cliente['telefono']),
                        _infoRow('Dirección', cliente['direccion']),
                        _infoRow('Tipo negocio', cliente['tipo_negocio']),
                        _infoRow('Nombre negocio', cliente['nombre_negocio']),
                        _infoRow(
                          'Ingresos estimados',
                          FormatUtils.currency(
                            (cliente['ingresos_estimados'] as num?) ?? 0,
                          ),
                        ),
                        _infoRow(
                          'Calificación SBS',
                          cliente['calificacion_sbs'],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppInfoCard(
                    child: Column(
                      children: [
                        const ConfianzaLogo(),
                        const SizedBox(height: 8),
                        Text(
                          AppConstants.appName,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkText.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
