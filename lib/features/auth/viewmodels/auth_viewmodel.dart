import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../../app/router.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/supabase/supabase_client.dart';
import '../services/auth_lookup_service.dart';
import '../../../core/security/login_guard.dart';
import '../models/auth_state.dart';

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> signIn(
    BuildContext context, {
    required String dni,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final lockMsg = await LoginGuard.lockMessage(dni);
      if (lockMsg != null) {
        throw Exception(lockMsg);
      }

      final email = await resolveEmailFromDni(dni);
      if (email == null) {
        throw Exception('DNI no registrado en el sistema');
      }

      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await LoginGuard.clear(dni);

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('No se pudo obtener la sesión del usuario');
      }

      final cliente = await supabase
          .from('clientes')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (cliente == null) {
        await supabase.auth.signOut();
        throw Exception('No se encontró el cliente vinculado a este usuario');
      }

      ref.read(clienteSessionProvider.notifier).state = cliente;
      state = state.copyWith(isLoading: false, isAuthenticated: true);

      if (context.mounted) {
        context.go(AppRoute.home.path);
      }
    } on AuthException catch (e) {
      await LoginGuard.recordFailure(dni);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      if (context.mounted) {
        _showError(context, e.message);
      }
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      if (!message.contains('Reintente')) {
        await LoginGuard.recordFailure(dni);
      }
      state = state.copyWith(isLoading: false, errorMessage: message);
      if (context.mounted) {
        _showError(context, message);
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await supabase.auth.signOut();
    } catch (_) {}
    ref.read(clienteSessionProvider.notifier).state = null;
    state = const AuthState();
    if (context.mounted) {
      context.go(AppRoute.auth.path);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
