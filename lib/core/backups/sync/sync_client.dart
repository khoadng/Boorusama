// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';

class SyncClientResult<T> {
  const SyncClientResult.success(this.data) : error = null;
  const SyncClientResult.failure(this.error) : data = null;

  final T? data;
  final String? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

class ConnectResult {
  const ConnectResult({required this.clientId});
  final String clientId;
}

class StageResult {
  const StageResult({required this.stagedCount});
  final int stagedCount;
}

class SyncStatusResult {
  const SyncStatusResult({required this.canPull, required this.phase});
  final bool canPull;
  final String phase;
}

class PullResult {
  const PullResult({required this.data});
  final List<Map<String, dynamic>> data;
}

class SyncClient {
  SyncClient({required this.baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

  final String baseUrl;
  final Dio _dio;

  Future<SyncClientResult<void>> checkHealth() async {
    try {
      await _dio.get('/health');
      return const SyncClientResult.success(null);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const SyncClientResult.failure(
          'Cannot connect to hub. Check the address and ensure the hub is running.',
        );
      }
      return SyncClientResult.failure(e.message ?? 'Connection failed');
    }
  }

  Future<SyncClientResult<ConnectResult>> connect({
    String? existingClientId,
    required String deviceName,
  }) async {
    try {
      final response = await _dio.post(
        '/connect',
        data: jsonEncode({
          'clientId': existingClientId,
          'deviceName': deviceName,
        }),
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode == 200) {
        final clientId = response.data['clientId'] as String?;
        if (clientId == null) {
          return const SyncClientResult.failure(
            'Hub did not return a clientId',
          );
        }
        return SyncClientResult.success(ConnectResult(clientId: clientId));
      }

      return SyncClientResult.failure(
        'Failed to connect: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return SyncClientResult.failure(e.message ?? 'Connection failed');
    }
  }

  Future<SyncClientResult<StageResult>> stageData({
    required String clientId,
    required String sourceId,
    required List<dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        '/stage/$sourceId',
        data: jsonEncode({
          'clientId': clientId,
          'data': data,
        }),
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode == 200) {
        final stagedCount = response.data['stagedCount'] as int? ?? data.length;
        return SyncClientResult.success(StageResult(stagedCount: stagedCount));
      }

      return SyncClientResult.failure(
        'Failed to stage: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return SyncClientResult.failure(e.message ?? 'Stage failed');
    }
  }

  Future<SyncClientResult<SyncStatusResult>> checkSyncStatus() async {
    try {
      final response = await _dio.get(
        '/sync/status',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final canPull = response.data['canPull'] as bool? ?? false;
      final phase = response.data['phase'] as String? ?? 'unknown';

      return SyncClientResult.success(
        SyncStatusResult(canPull: canPull, phase: phase),
      );
    } on DioException catch (e) {
      return SyncClientResult.failure(e.message ?? 'Status check failed');
    }
  }

  Future<SyncClientResult<PullResult>> pullData(String sourceId) async {
    try {
      final response = await _dio.get('/pull/$sourceId');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>?;
        return SyncClientResult.success(
          PullResult(
            data: data?.map((e) => e as Map<String, dynamic>).toList() ?? [],
          ),
        );
      }

      if (response.statusCode == 404) {
        return const SyncClientResult.success(PullResult(data: []));
      }

      return SyncClientResult.failure('Failed to pull: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const SyncClientResult.success(PullResult(data: []));
      }
      return SyncClientResult.failure(e.message ?? 'Pull failed');
    }
  }

  void dispose() {
    _dio.close();
  }
}
