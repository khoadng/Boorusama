// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';

sealed class NetworkState {}

final class NetworkInitialState extends NetworkState {}

final class NetworkLoadingState extends NetworkState {}

final class NetworkConnectedState extends NetworkState {
  NetworkConnectedState({
    required this.result,
  });

  final ConnectivityResult result;
}

final class NetworkDisconnectedState extends NetworkState {}

extension ConnectivityResultX on ConnectivityResult {
  bool get isMobile => switch (this) {
        ConnectivityResult.wifi => true,
        _ => false,
      };
}
