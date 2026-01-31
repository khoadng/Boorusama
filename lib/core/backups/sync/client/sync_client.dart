// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../sync_dto.dart';

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

class StageBeginResult {
  const StageBeginResult();
}

class StageResult {
  const StageResult({required this.stagedCount});
  final int stagedCount;
}

class StageCompleteResult {
  const StageCompleteResult({required this.sourcesStaged});
  final int sourcesStaged;
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

class PullAllResult {
  const PullAllResult({required this.sources});
  final Map<String, List<Map<String, dynamic>>> sources;
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
      final requestDto = ConnectRequestDto(
        clientId: existingClientId,
        deviceName: deviceName,
      );

      final response = await _dio.post(
        '/connect',
        data: jsonEncode(requestDto.toJson()),
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode == 200) {
        final dto = ConnectResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
        return SyncClientResult.success(ConnectResult(clientId: dto.clientId));
      }

      return SyncClientResult.failure(
        'Failed to connect: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return SyncClientResult.failure(e.message ?? 'Connection failed');
    }
  }

  Future<SyncClientResult<StageBeginResult>> stageBegin({
    required String clientId,
    required List<String> expectedSources,
  }) async {
    try {
      final requestDto = StageBeginRequestDto(
        clientId: clientId,
        expectedSources: expectedSources,
      );

      final response = await _dio.post(
        '/stage/begin',
        data: jsonEncode(requestDto.toJson()),
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode == 200) {
        return const SyncClientResult.success(StageBeginResult());
      }

      return SyncClientResult.failure(
        'Failed to begin staging: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return SyncClientResult.failure(e.message ?? 'Stage begin failed');
    }
  }

  Future<SyncClientResult<StageResult>> stageData({
    required String clientId,
    required String sourceId,
    required List<dynamic> data,
  }) async {
    try {
      final requestDto = StageRequestDto(
        clientId: clientId,
        data: data.map((e) => e as Map<String, dynamic>).toList(),
      );

      final response = await _dio.post(
        '/stage/$sourceId',
        data: jsonEncode(requestDto.toJson()),
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode == 200) {
        final dto = StageResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
        return SyncClientResult.success(
          StageResult(stagedCount: dto.stagedCount),
        );
      }

      return SyncClientResult.failure(
        'Failed to stage: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return SyncClientResult.failure(e.message ?? 'Stage failed');
    }
  }

  Future<SyncClientResult<StageCompleteResult>> stageComplete({
    required String clientId,
  }) async {
    try {
      final requestDto = StageCompleteRequestDto(clientId: clientId);

      final response = await _dio.post(
        '/stage/complete',
        data: jsonEncode(requestDto.toJson()),
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return SyncClientResult.success(
          StageCompleteResult(
            sourcesStaged: data['sourcesStaged'] as int? ?? 0,
          ),
        );
      }

      final body = response.data?.toString() ?? '';
      return SyncClientResult.failure('Staging incomplete: $body');
    } on DioException catch (e) {
      final body = e.response?.data?.toString() ?? e.message ?? '';
      return SyncClientResult.failure('Staging incomplete: $body');
    }
  }

  Future<SyncClientResult<SyncStatusResult>> checkSyncStatus() async {
    try {
      final response = await _dio.get(
        '/sync/status',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );

      final dto = SyncStatusDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      return SyncClientResult.success(
        SyncStatusResult(canPull: dto.canPull, phase: dto.phase),
      );
    } on DioException catch (e) {
      return SyncClientResult.failure(e.message ?? 'Status check failed');
    }
  }

  Future<SyncClientResult<PullResult>> pullData(String sourceId) async {
    try {
      final response = await _dio.get('/pull/$sourceId');

      if (response.statusCode == 200) {
        final dto = PullResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
        return SyncClientResult.success(PullResult(data: dto.data));
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

  Future<SyncClientResult<PullAllResult>> pullAll() async {
    try {
      final response = await _dio.get('/pull/all');

      if (response.statusCode == 200) {
        final dto = PullAllResponseDto.fromJson(
          response.data as Map<String, dynamic>,
        );
        return SyncClientResult.success(PullAllResult(sources: dto.sources));
      }

      return SyncClientResult.failure('Failed to pull: ${response.statusCode}');
    } on DioException catch (e) {
      return SyncClientResult.failure(e.message ?? 'Pull failed');
    }
  }

  Future<SyncClientResult<void>> pullComplete({
    required String clientId,
  }) async {
    try {
      final response = await _dio.post(
        '/pull/complete',
        data: jsonEncode({'clientId': clientId}),
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode == 200) {
        return const SyncClientResult.success(null);
      }

      return SyncClientResult.failure(
        'Failed to complete pull: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return SyncClientResult.failure(e.message ?? 'Pull complete failed');
    }
  }

  void dispose() {
    _dio.close();
  }
}
