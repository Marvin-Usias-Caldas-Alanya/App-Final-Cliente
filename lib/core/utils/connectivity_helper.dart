import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.onConnectivityChanged;
});

Future<bool> hasNetworkConnection(Connectivity connectivity) async {
  final results = await connectivity.checkConnectivity();
  return !results.contains(ConnectivityResult.none);
}
