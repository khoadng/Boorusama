// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/networking.dart';
import '../../servers/server.dart';

enum ServerStatus {
  stopped,
  running,
  broadcasting,
}

class ExportDataState extends Equatable {
  const ExportDataState({
    required this.status,
    required this.ipAddress,
    required this.port,
    required this.serverName,
    required this.appVersion,
  });

  const ExportDataState.initial()
    : status = ServerStatus.stopped,
      ipAddress = '',
      port = '',
      serverName = '',
      appVersion = '';

  const ExportDataState.invalid()
    : status = ServerStatus.stopped,
      ipAddress = 'null',
      port = 'null',
      serverName = '',
      appVersion = '';

  final ServerStatus status;
  final String ipAddress;
  final String port;
  final String serverName;
  final String appVersion;

  String get serverUrl => 'http://$ipAddress:$port';

  @override
  List<Object?> get props => [status, ipAddress, port, serverName, appVersion];
}

final exportDataProvider =
    AsyncNotifierProvider.autoDispose<ExportDataNotifier, ExportDataState>(
      ExportDataNotifier.new,
    );

class ExportDataNotifier extends AutoDisposeAsyncNotifier<ExportDataState> {
  @override
  FutureOr<ExportDataState> build() async {
    final server = ref.watch(dataSyncServerProvider);

    final localIpAddress = await ref.watch(localIPAddressProvider.future);

    if (localIpAddress == null) {
      return const ExportDataState.invalid();
    }

    final serverInfo = await server.startServer(localIpAddress);

    if (serverInfo == null) {
      return const ExportDataState.invalid();
    }

    await Future.delayed(const Duration(milliseconds: 500));

    await server.startBroadcast();

    return ExportDataState(
      status: server.isRunning
          ? server.isBroadcasting
                ? ServerStatus.broadcasting
                : ServerStatus.running
          : ServerStatus.stopped,
      ipAddress: serverInfo.host,
      port: serverInfo.port.toString(),
      serverName: server.serverName,
      appVersion: server.appVersion,
    );
  }

  void stopServer() {
    ref.read(dataSyncServerProvider).stopServer();
    state = const AsyncValue.data(ExportDataState.initial());
  }
}
