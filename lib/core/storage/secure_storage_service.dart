import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) {
    return _storage.read(key: key);
  }

  Future<void> delete({required String key}) {
    return _storage.delete(key: key);
  }

  Future<void> deleteAll() {
    return _storage.deleteAll();
  }
}
