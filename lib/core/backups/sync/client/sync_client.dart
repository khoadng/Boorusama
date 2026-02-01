// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Project imports:
import '../sync_dto.dart';
import 'sync_client_repo.dart';

class SyncClientResult<T> {
  const SyncClientResult.success(this.data) : error = null;
  const SyncClientResult.failure(this.error) : data = null;

  final T? data;
  final String? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

class ConnectResult {
  const ConnectResult({required this.clientId, required this.phase});
  final String clientId;
  final String phase;
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

/// Message types received from hub
enum HubMessageType {
  connected,
  syncConfirmed,
  syncReset,
  error,
}

class SyncClient {
  SyncClient({
    required this.baseUrl,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: const Duration(seconds: 10),
           receiveTimeout: const Duration(seconds: 30),
           sendTimeout: const Duration(seconds: 30),
         ),
       );

  final String baseUrl;
  final Dio _dio;

  // WebSocket connection
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  // Event stream
  final _eventController = StreamController<SyncEvent>.broadcast();
  Stream<SyncEvent> get events => _eventController.stream;

  bool get isConnected => _channel != null;

  String get _wsUrl {
    final uri = Uri.parse(baseUrl);
    return 'ws://${uri.host}:${uri.port}/ws';
  }

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
      // Close existing connection if any
      await disconnect();

      // Connect via WebSocket
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

      final completer = Completer<SyncClientResult<ConnectResult>>();

      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message as String, completer);
        },
        onDone: () {
          _channel = null;
          _subscription = null;
          _eventController.add(SyncDisconnectedEvent());
        },
        onError: (error) {
          if (!completer.isCompleted) {
            completer.complete(
              SyncClientResult.failure('WebSocket error: $error'),
            );
          }
          _channel = null;
          _subscription = null;
          _eventController.add(SyncDisconnectedEvent());
        },
      );

      // Send connect message
      _channel!.sink.add(
        jsonEncode({
          'action': 'connect',
          'deviceName': deviceName,
          'clientId': ?existingClientId,
        }),
      );

      // Wait for connected response with timeout
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          disconnect();
          return const SyncClientResult.failure('Connection timeout');
        },
      );
    } catch (e) {
      return SyncClientResult.failure('Failed to connect: $e');
    }
  }

  void _handleMessage(
    String message,
    Completer<SyncClientResult<ConnectResult>>? connectCompleter,
  ) {
    try {
      final json = jsonDecode(message) as Map<String, dynamic>;
      final type = json['type'] as String?;
      final data = json['data'] as Map<String, dynamic>?;

      switch (type) {
        case 'connected':
          if (connectCompleter != null && !connectCompleter.isCompleted) {
            final clientId = data?['clientId'] as String?;
            final phase = data?['phase'] as String? ?? 'waiting';
            if (clientId != null) {
              connectCompleter.complete(
                SyncClientResult.success(
                  ConnectResult(clientId: clientId, phase: phase),
                ),
              );
            } else {
              connectCompleter.complete(
                const SyncClientResult.failure('No clientId in response'),
              );
            }
          }

        case 'syncConfirmed':
          _eventController.add(SyncConfirmedEvent());

        case 'syncReset':
          _eventController.add(SyncResetEvent());

        case 'error':
          final errorMsg = data?['message'] as String? ?? 'Unknown error';
          _eventController.add(SyncErrorEvent(errorMsg));
          if (connectCompleter != null && !connectCompleter.isCompleted) {
            connectCompleter.complete(SyncClientResult.failure(errorMsg));
          }
      }
    } catch (e) {
      _eventController.add(SyncErrorEvent('Failed to parse message: $e'));
    }
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  // HTTP methods for data transfer (unchanged)

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
    disconnect();
    _eventController.close();
    _dio.close();
  }
}
