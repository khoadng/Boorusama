// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import '../types/backup_data_source.dart';
import '../types/backup_registry.dart';
import 'sync_client.dart';

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

class SyncService {
  SyncService({
    required this.client,
    required this.registry,
    required this.deviceName,
  });

  final SyncClient client;
  final BackupRegistry registry;
  final String deviceName;

  Future<StageToHubResult> stageToHub({String? existingClientId}) async {
    // Check health
    final healthResult = await client.checkHealth();
    if (healthResult.isFailure) {
      return StageToHubResult.failure(healthResult.error);
    }

    // Connect
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

  Future<PullFromHubResult> pullFromHub() async {
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

    return const PullFromHubResult.success();
  }

  Future<SyncClientResult<SyncStatusResult>> checkStatus() =>
      client.checkSyncStatus();

  Future<String?> _stageAllSources(String clientId) async {
    var stagedCount = 0;

    for (final source in registry.getAllSources()) {
      if (source.capabilities.sync == null) continue;

      try {
        final data = await _exportSourceData(source);

        final result = await client.stageData(
          clientId: clientId,
          sourceId: source.id,
          data: data,
        );

        if (result.isSuccess) stagedCount++;
      } catch (e) {
        // Continue with other sources
      }
    }

    return stagedCount > 0 ? null : 'Failed to stage any data';
  }

  Future<String?> _pullAllSources() async {
    for (final source in registry.getAllSources()) {
      final syncCapability = source.capabilities.sync;
      if (syncCapability == null) continue;

      try {
        final result = await client.pullData(source.id);
        if (result.isFailure || result.data!.data.isEmpty) continue;

        await syncCapability.importResolved(result.data!.data);
      } catch (e) {
        // Continue with other sources
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

  void dispose() {
    client.dispose();
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
