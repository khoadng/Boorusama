// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final networkStatusProvider =
    StreamProvider.autoDispose<NetworkStatus>((ref) async* {
  final connectivity = Connectivity();
  await for (final event in connectivity.onConnectivityChanged) {
    if (event == ConnectivityResult.none) {
      yield NetworkStatus.unavailable;
    } else {
      yield NetworkStatus.available;
    }
  }
});

enum NetworkStatus { unknown, available, unavailable }
