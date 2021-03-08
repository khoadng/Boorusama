// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'network_info.freezed.dart';

final networkStatusProvider =
    StreamProvider.autoDispose<NetworkStatus>((ref) async* {
  final connectivity = Connectivity();
  await for (final event in connectivity.onConnectivityChanged) {
    if (event == ConnectivityResult.none) {
      yield NetworkStatus.unavailable();
    } else {
      yield NetworkStatus.available();
    }
  }
});

@freezed
abstract class NetworkStatus with _$NetworkStatus {
  const factory NetworkStatus.unknown() = _Unknown;
  const factory NetworkStatus.available() = _Available;
  const factory NetworkStatus.unavailable() = _Unavailable;
}
