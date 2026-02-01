// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import '../../types/backup_data_source.dart';
import '../../types/backup_registry.dart';
import 'sync_client.dart';
import 'sync_client_repo.dart';

class StageToHubResult {
  const StageToHubResult.success({required this.clientId}) : error = null;
  const StageToHubResult.failure(this.error) : clientId = null;

  final String? clientId;
  final String? error;

  bool get isSuccess => error == null;
}

class PullFromHubResult {
  const PullFromHubResult.success() : error = null;
  const PullFromHubResult.failure(this.error);

  final String? error;

  bool get isSuccess => error == null;
}

/// Implements SyncClientRepo for sync operations.
class SyncService implements SyncClientRepo {
  SyncService({
    required this.client,
    required this.registry,
    required this.deviceName,
  });

  final SyncClient client;
  final BackupRegistry registry;
  final String deviceName;

  @override
  Stream<SyncEvent> get events => client.events;

  @override
  void disconnect() => client.disconnect();

  @override
  void dispose() => client.dispose();

  @override
  Future<StageToHubResult> stageToHub({String? existingClientId}) async {
    // Check health
    final healthResult = await client.checkHealth();
    if (healthResult.isFailure) {
      return StageToHubResult.failure(healthResult.error);
    }

    // Connect via WebSocket
    final connectResult = await client.connect(
      existingClientId: existingClientId,
      deviceName: deviceName,
    );
    if (connectResult.isFailure) {
      return StageToHubResult.failure(connectResult.error);
    }

    final clientId = connectResult.data!.clientId;

    // Stage all sources
    final stageError = await _stageAllSources(clientId);
    if (stageError != null) {
      return StageToHubResult.failure(stageError);
    }

    return StageToHubResult.success(clientId: clientId);
  }

  @override
  Future<PullFromHubResult> pullFromHub({String? clientId}) async {
    final statusResult = await client.checkSyncStatus();
    if (statusResult.isFailure) {
      return PullFromHubResult.failure(statusResult.error);
    }

    if (!statusResult.data!.canPull) {
      return const PullFromHubResult.failure('Hub sync not confirmed yet');
    }

    final pullError = await _pullAllSources();
    if (pullError != null) {
      return PullFromHubResult.failure(pullError);
    }

    // Notify hub that pull is complete
    if (clientId != null) {
      await client.pullComplete(clientId: clientId);
    }

    return const PullFromHubResult.success();
  }

  Future<SyncClientResult<SyncStatusResult>> checkStatus() =>
      client.checkSyncStatus();

  Future<String?> _stageAllSources(String clientId) async {
    // Get all syncable sources
    final syncableSources = registry
        .getAllSources()
        .where((s) => s.capabilities.sync != null)
        .toList();

    if (syncableSources.isEmpty) {
      return 'No syncable sources available';
    }

    // Begin staging - declare what we intend to stage
    final sourceIds = syncableSources.map((s) => s.id).toList();
    final beginResult = await client.stageBegin(
      clientId: clientId,
      expectedSources: sourceIds,
    );

    if (beginResult.isFailure) {
      return beginResult.error;
    }

    // Stage each source
    for (final source in syncableSources) {
      try {
        final data = await _exportSourceData(source);

        await client.stageData(
          clientId: clientId,
          sourceId: source.id,
          data: data,
        );
      } catch (e) {
        // Continue with other sources
      }
    }

    // Complete staging
    final completeResult = await client.stageComplete(clientId: clientId);

    if (completeResult.isFailure) {
      return completeResult.error;
    }

    return null;
  }

  Future<String?> _pullAllSources() async {
    // Atomic pull: fetch all data in one request
    final pullResult = await client.pullAll();
    if (pullResult.isFailure) {
      return pullResult.error;
    }

    final allSources = pullResult.data!.sources;

    // Import all sources locally
    for (final entry in allSources.entries) {
      final sourceId = entry.key;
      final data = entry.value;

      if (data.isEmpty) continue;

      final source = registry.getSource(sourceId);
      final syncCapability = source?.capabilities.sync;
      if (syncCapability == null) continue;

      try {
        await syncCapability.importResolved(data);
      } catch (e) {
        // Log error but continue - local import failures are bugs
      }
    }

    return null;
  }

  Future<List<dynamic>> _exportSourceData(BackupDataSource source) async {
    final request = shelf.Request('GET', Uri.parse('http://localhost/'));
    final response = await source.capabilities.server.export(request);
    final exportData = await response.readAsString();
    final parsed = jsonDecode(exportData);

    return switch (parsed) {
      {'data': final List data} => data,
      final List data => data,
      _ => <dynamic>[],
    };
  }
}

String normalizeHubAddress(String address) {
  var normalized = address.trim();
  if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
    normalized = 'http://$normalized';
  }
  if (normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}
