// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';

// Project imports:
import 'connectivity_service.dart';

final class PluginConnectivityService implements ConnectivityService {
  PluginConnectivityService({
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<List<ConnectivityResult>> get changes =>
      _connectivity.onConnectivityChanged;

  @override
  Future<List<ConnectivityResult>> getCurrent() =>
      _connectivity.checkConnectivity();
}
