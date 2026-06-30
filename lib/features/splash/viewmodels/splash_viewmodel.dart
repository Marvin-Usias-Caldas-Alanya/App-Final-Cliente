import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/session_provider.dart';
import '../../../core/supabase/supabase_client.dart';

enum SplashNavigationTarget { none, auth, home }

final splashViewModelProvider =
    NotifierProvider<SplashViewModel, SplashNavigationTarget>(
  SplashViewModel.new,
);

class SplashViewModel extends Notifier<SplashNavigationTarget> {
  @override
  SplashNavigationTarget build() => SplashNavigationTarget.none;

  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    try {
      Supabase.instance.client;
    } catch (_) {
      state = SplashNavigationTarget.auth;
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      state = SplashNavigationTarget.auth;
      return;
    }

    try {
      final cliente = await supabase
          .from('clientes')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (cliente != null) {
        ref.read(clienteSessionProvider.notifier).state = cliente;
        state = SplashNavigationTarget.home;
        return;
      }
    } catch (_) {}

    state = SplashNavigationTarget.auth;
  }
}
