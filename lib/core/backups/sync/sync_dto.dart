// Project imports:
import 'hub/types.dart';

// ===== WebSocket Messages =====

enum WsMessageType {
  connected,
  syncConfirmed,
  syncReset,
  error,
}

enum WsActionType {
  connect,
}

class WsMessage {
  const WsMessage({required this.type, this.data});

  factory WsMessage.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    return WsMessage(
      type: WsMessageType.values.where((e) => e.name == typeStr).firstOrNull,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  final WsMessageType? type;
  final Map<String, dynamic>? data;

  Map<String, dynamic> toJson() => {
    'type': type?.name,
    if (data != null) 'data': data,
  };
}

class WsConnectAction {
  const WsConnectAction({this.clientId, required this.deviceName});

  factory WsConnectAction.fromJson(Map<String, dynamic> json) =>
      WsConnectAction(
        clientId: json['clientId'] as String?,
        deviceName: json['deviceName'] as String? ?? 'Unknown',
      );

  final String? clientId;
  final String deviceName;

  Map<String, dynamic> toJson() => {
    'action': WsActionType.connect.name,
    'clientId': clientId,
    'deviceName': deviceName,
  };
}

class WsConnectedData {
  const WsConnectedData({required this.clientId, required this.phase});

  factory WsConnectedData.fromJson(Map<String, dynamic> json) {
    final phaseStr = json['phase'] as String?;
    return WsConnectedData(
      clientId: json['clientId'] as String? ?? '',
      phase:
          SyncHubPhase.values.where((e) => e.name == phaseStr).firstOrNull ??
          SyncHubPhase.waiting,
    );
  }

  final String clientId;
  final SyncHubPhase phase;

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'phase': phase.name,
  };

  WsMessage toMessage() => WsMessage(
    type: WsMessageType.connected,
    data: toJson(),
  );
}

class WsErrorData {
  const WsErrorData({required this.message});

  factory WsErrorData.fromJson(Map<String, dynamic> json) => WsErrorData(
    message: json['message'] as String? ?? 'Unknown error',
  );

  final String message;

  Map<String, dynamic> toJson() => {'message': message};

  WsMessage toMessage() => WsMessage(
    type: WsMessageType.error,
    data: toJson(),
  );
}

// ===== HTTP DTOs =====

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

// Stage Begin
class StageBeginRequestDto {
  const StageBeginRequestDto({
    required this.clientId,
    required this.expectedSources,
  });

  factory StageBeginRequestDto.fromJson(Map<String, dynamic> json) {
    final sources = (json['expectedSources'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();

    return StageBeginRequestDto(
      clientId: json['clientId'] as String?,
      expectedSources: sources ?? [],
    );
  }

  final String? clientId;
  final List<String> expectedSources;

  Map<String, dynamic> toJson() => {
    'clientId': clientId,
    'expectedSources': expectedSources,
  };
}

class StageBeginResponseDto {
  const StageBeginResponseDto();

  Map<String, dynamic> toJson() => {'success': true};
}

// Stage Complete
class StageCompleteRequestDto {
  const StageCompleteRequestDto({required this.clientId});

  factory StageCompleteRequestDto.fromJson(Map<String, dynamic> json) =>
      StageCompleteRequestDto(clientId: json['clientId'] as String?);

  final String? clientId;

  Map<String, dynamic> toJson() => {'clientId': clientId};
}

class StageCompleteResponseDto {
  const StageCompleteResponseDto({required this.sourcesStaged});

  final int sourcesStaged;

  Map<String, dynamic> toJson() => {
    'success': true,
    'sourcesStaged': sourcesStaged,
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

class PullAllResponseDto {
  const PullAllResponseDto({required this.sources});

  factory PullAllResponseDto.fromJson(Map<String, dynamic> json) {
    final sourcesJson = json['sources'] as Map<String, dynamic>? ?? {};
    final sources = <String, List<Map<String, dynamic>>>{};

    for (final entry in sourcesJson.entries) {
      final rawList = entry.value as List<dynamic>?;
      sources[entry.key] =
          rawList?.map((e) => e as Map<String, dynamic>).toList() ?? [];
    }

    return PullAllResponseDto(sources: sources);
  }

  final Map<String, List<Map<String, dynamic>>> sources;

  Map<String, dynamic> toJson() => {'sources': sources};
}

// Hub Status
class HubStatusDto {
  const HubStatusDto({
    required this.isRunning,
    required this.serverUrl,
    required this.phase,
    required this.connectedClients,
    required this.totalStagedClients,
    required this.totalPulledClients,
    required this.pullProgress,
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
    totalPulledClients: state.totalPulledClients,
    pullProgress: state.pullProgress,
    conflictsCount: state.conflicts.length,
    hasUnresolvedConflicts: state.hasUnresolvedConflicts,
    canConfirm: state.canConfirm,
  );

  final bool isRunning;
  final String? serverUrl;
  final String phase;
  final List<ConnectedClientDto> connectedClients;
  final int totalStagedClients;
  final int totalPulledClients;
  final String pullProgress;
  final int conflictsCount;
  final bool hasUnresolvedConflicts;
  final bool canConfirm;

  Map<String, dynamic> toJson() => {
    'isRunning': isRunning,
    'serverUrl': serverUrl,
    'phase': phase,
    'connectedClients': connectedClients.map((c) => c.toJson()).toList(),
    'totalStagedClients': totalStagedClients,
    'totalPulledClients': totalPulledClients,
    'pullProgress': pullProgress,
    'conflictsCount': conflictsCount,
    'hasUnresolvedConflicts': hasUnresolvedConflicts,
    'canConfirm': canConfirm,
  };
}

class ConnectedClientDto {
  const ConnectedClientDto({
    required this.id,
    required this.deviceName,
    required this.connectedAt,
    required this.expectedSources,
    required this.stagedSources,
    required this.stagingComplete,
    required this.hasStaged,
    required this.isStaging,
    required this.stagingProgress,
    required this.hasPulled,
  });

  factory ConnectedClientDto.fromModel(ConnectedClient client) =>
      ConnectedClientDto(
        id: client.id,
        deviceName: client.deviceName,
        connectedAt: client.connectedAt.toIso8601String(),
        expectedSources: client.expectedSources,
        stagedSources: client.stagedSources,
        stagingComplete: client.stagingComplete,
        hasStaged: client.hasStaged,
        isStaging: client.isStaging,
        stagingProgress: client.stagingProgress,
        hasPulled: client.hasPulled,
      );

  final String id;
  final String deviceName;
  final String connectedAt;
  final List<String> expectedSources;
  final List<String> stagedSources;
  final bool stagingComplete;
  final bool hasStaged;
  final bool isStaging;
  final String stagingProgress;
  final bool hasPulled;

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceName': deviceName,
    'connectedAt': connectedAt,
    'expectedSources': expectedSources,
    'stagedSources': stagedSources,
    'stagingComplete': stagingComplete,
    'hasStaged': hasStaged,
    'isStaging': isStaging,
    'stagingProgress': stagingProgress,
    'hasPulled': hasPulled,
  };
}
