// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';

sealed class NetworkState {}

final class NetworkInitialState extends NetworkState {}

final class NetworkLoadingState extends NetworkState {}

final class NetworkConnectedState extends NetworkState {
  NetworkConnectedState({
    required this.result,
  });

  final List<ConnectivityResult> result;
}

final class NetworkDisconnectedState extends NetworkState {}

extension ConnectivityResultX on List<ConnectivityResult> {
  bool get isMobile => length == 1 && contains(ConnectivityResult.mobile);

  String get prettyString {
    if (isEmpty) return 'none';

    return map((e) => e.name).join(', ');
  }
}
