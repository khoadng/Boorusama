// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class ConnectivityService {
  Stream<List<ConnectivityResult>> get changes;

  Future<List<ConnectivityResult>> getCurrent();
}

final connectivityServiceProvider = Provider<ConnectivityService>(
  (_) => throw UnimplementedError(),
  name: 'connectivityServiceProvider',
);
