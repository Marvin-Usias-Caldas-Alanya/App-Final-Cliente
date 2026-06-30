import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/views/auth_view.dart';
import '../features/creditos/views/detalle_credito_view.dart';
import '../features/creditos/views/mis_creditos_view.dart';
import '../features/home/views/home_view.dart';
import '../features/movimientos/views/movimientos_view.dart';
import '../features/perfil/views/perfil_view.dart';
import '../features/solicitudes/views/nueva_solicitud_view.dart';
import '../features/solicitudes/views/solicitudes_cliente_view.dart';
import '../features/splash/views/splash_view.dart';

enum AppRoute {
  splash('/'),
  auth('/auth'),
  home('/home'),
  creditos('/creditos'),
  detalleCredito('/credito/:creditoId'),
  movimientos('/movimientos'),
  solicitudes('/solicitudes'),
  nuevaSolicitud('/solicitudes/nueva'),
  perfil('/perfil');

  const AppRoute(this.path);
  final String path;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.splash.path,
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppRoute.auth.path,
        builder: (context, state) => const AuthView(),
      ),
      GoRoute(
        path: AppRoute.home.path,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: AppRoute.creditos.path,
        builder: (context, state) => const MisCreditosView(),
      ),
      GoRoute(
        path: AppRoute.detalleCredito.path,
        builder: (context, state) {
          final creditoId = state.pathParameters['creditoId']!;
          return DetalleCreditoView(creditoId: creditoId);
        },
      ),
      GoRoute(
        path: AppRoute.movimientos.path,
        builder: (context, state) => const MovimientosView(),
      ),
      GoRoute(
        path: AppRoute.solicitudes.path,
        builder: (context, state) => const SolicitudesClienteView(),
      ),
      GoRoute(
        path: AppRoute.nuevaSolicitud.path,
        builder: (context, state) => const NuevaSolicitudView(),
      ),
      GoRoute(
        path: AppRoute.perfil.path,
        builder: (context, state) => const PerfilView(),
      ),
    ],
  );
});
