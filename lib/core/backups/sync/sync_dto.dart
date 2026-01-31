// Project imports:
import 'types.dart';

// Connect
class ConnectRequestDto {
  const ConnectRequestDto({
    this.clientId,
    required this.deviceName,
  });

  factory ConnectRequestDto.fromJson(Map<String, dynamic> json) =>
      ConnectRequestDto(
        clientId: json['clientId'] as String?,
        deviceName: json['deviceName'] as String? ?? 'Unknown Device',
      );

  final String? clientId;
  final String deviceName;

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'deviceName': deviceName,
  };
}

class ConnectResponseDto {
  const ConnectResponseDto({
    required this.clientId,
    required this.phase,
  });

  factory ConnectResponseDto.fromJson(Map<String, dynamic> json) =>
      ConnectResponseDto(
        clientId: json['clientId'] as String,
        phase: json['phase'] as String,
      );

  final String clientId;
  final String phase;

  Map<String, dynamic> toJson() => {
    'success': true,
    'clientId': clientId,
    'phase': phase,
  };
}

// Stage
class StageRequestDto {
  const StageRequestDto({
    required this.clientId,
    required this.data,
  });

  factory StageRequestDto.fromJson(Map<String, dynamic> json) {
    final rawData = switch (json) {
      {'data': final List<dynamic> data} => data,
      _ => <dynamic>[],
    };

    return StageRequestDto(
      clientId: json['clientId'] as String?,
      data: rawData.map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  final String? clientId;
  final List<Map<String, dynamic>> data;

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'data': data,
  };
}

class StageResponseDto {
  const StageResponseDto({required this.stagedCount});

  factory StageResponseDto.fromJson(Map<String, dynamic> json) =>
      StageResponseDto(
        stagedCount: json['stagedCount'] as int? ?? 0,
      );

  final int stagedCount;

  Map<String, dynamic> toJson() => {
    'success': true,
    'stagedCount': stagedCount,
  };
}

// Sync Status
class SyncStatusDto {
  const SyncStatusDto({
    required this.phase,
    required this.canPull,
  });

  factory SyncStatusDto.fromJson(Map<String, dynamic> json) => SyncStatusDto(
    phase: json['phase'] as String? ?? 'unknown',
    canPull: json['canPull'] as bool? ?? false,
  );

  final String phase;
  final bool canPull;

  Map<String, dynamic> toJson() => {
    'phase': phase,
    'canPull': canPull,
  };
}

// Pull
class PullResponseDto {
  const PullResponseDto({required this.data});

  factory PullResponseDto.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>?;
    return PullResponseDto(
      data: rawData?.map((e) => e as Map<String, dynamic>).toList() ?? [],
    );
  }

  final List<Map<String, dynamic>> data;

  Map<String, dynamic> toJson() => {'data': data};
}

// Hub Status
class HubStatusDto {
  const HubStatusDto({
    required this.isRunning,
    required this.serverUrl,
    required this.phase,
    required this.connectedClients,
    required this.totalStagedClients,
    required this.conflictsCount,
    required this.hasUnresolvedConflicts,
    required this.canConfirm,
  });

  factory HubStatusDto.fromState(SyncHubState state) => HubStatusDto(
    isRunning: state.isRunning,
    serverUrl: state.serverUrl,
    phase: state.phase.name,
    connectedClients: state.connectedClients
        .map((c) => ConnectedClientDto.fromModel(c))
        .toList(),
    totalStagedClients: state.totalStagedClients,
    conflictsCount: state.conflicts.length,
    hasUnresolvedConflicts: state.hasUnresolvedConflicts,
    canConfirm: state.canConfirm,
  );

  final bool isRunning;
  final String? serverUrl;
  final String phase;
  final List<ConnectedClientDto> connectedClients;
  final int totalStagedClients;
  final int conflictsCount;
  final bool hasUnresolvedConflicts;
  final bool canConfirm;

  Map<String, dynamic> toJson() => {
    'isRunning': isRunning,
    'serverUrl': serverUrl,
    'phase': phase,
    'connectedClients': connectedClients.map((c) => c.toJson()).toList(),
    'totalStagedClients': totalStagedClients,
    'conflictsCount': conflictsCount,
    'hasUnresolvedConflicts': hasUnresolvedConflicts,
    'canConfirm': canConfirm,
  };
}

class ConnectedClientDto {
  const ConnectedClientDto({
    required this.id,
    required this.address,
    required this.deviceName,
    required this.connectedAt,
    this.stagedAt,
    required this.hasStaged,
  });

  factory ConnectedClientDto.fromModel(ConnectedClient client) =>
      ConnectedClientDto(
        id: client.id,
        address: client.address,
        deviceName: client.deviceName,
        connectedAt: client.connectedAt.toIso8601String(),
        stagedAt: client.stagedAt?.toIso8601String(),
        hasStaged: client.hasStaged,
      );

  final String id;
  final String address;
  final String deviceName;
  final String connectedAt;
  final String? stagedAt;
  final bool hasStaged;

  Map<String, dynamic> toJson() => {
    'id': id,
    'address': address,
    'deviceName': deviceName,
    'connectedAt': connectedAt,
    'stagedAt': stagedAt,
    'hasStaged': hasStaged,
  };
}
