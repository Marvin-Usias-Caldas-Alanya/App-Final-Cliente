/// Bloqueo temporal tras intentos fallidos de login (Play Store / seguridad).
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract final class LoginGuard {
  static const _storage = FlutterSecureStorage();
  static const maxAttempts = 5;
  static const lockMinutes = 15;

  static String _key(String id) => 'login_attempts_$id';

  static Future<bool> isLocked(String identifier) async {
    final raw = await _storage.read(key: _key(identifier));
    if (raw == null) return false;
    final parts = raw.split('|');
    if (parts.length != 2) return false;
    final count = int.tryParse(parts[0]) ?? 0;
    final lockedUntil = DateTime.tryParse(parts[1]);
    if (count < maxAttempts || lockedUntil == null) return false;
    if (DateTime.now().isBefore(lockedUntil)) return true;
    await clear(identifier);
    return false;
  }

  static Future<String?> lockMessage(String identifier) async {
    if (!await isLocked(identifier)) return null;
    final raw = await _storage.read(key: _key(identifier));
    final lockedUntil = DateTime.tryParse(raw!.split('|')[1]);
    if (lockedUntil == null) return 'Cuenta bloqueada temporalmente.';
    final mins = lockedUntil.difference(DateTime.now()).inMinutes + 1;
    return 'Demasiados intentos. Reintente en $mins min.';
  }

  static Future<void> recordFailure(String identifier) async {
    final raw = await _storage.read(key: _key(identifier));
    var count = 0;
    if (raw != null) {
      count = int.tryParse(raw.split('|').first) ?? 0;
    }
    count += 1;
    var lockedUntil = '';
    if (count >= maxAttempts) {
      lockedUntil = DateTime.now()
          .add(const Duration(minutes: lockMinutes))
          .toIso8601String();
    }
    await _storage.write(key: _key(identifier), value: '$count|$lockedUntil');
  }

  static Future<void> clear(String identifier) async {
    await _storage.delete(key: _key(identifier));
  }
}
