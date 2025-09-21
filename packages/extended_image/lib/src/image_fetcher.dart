// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:retriable/retriable.dart';

class ImageFetcher {
  static Future<Uint8List> fetchImageBytes({
    required String url,
    required Dio dio,
    Map<String, String>? headers,
    FetchStrategyBuilder? fetchStrategy,
    CancelToken? cancelToken,
    void Function(int count, int total)? onReceiveProgress,
    bool printError = true,
  }) async {
    try {
      final resolved = Uri.base.resolve(url);

      final response = await tryGetResponse<List<int>>(
        resolved,
        dio: dio,
        cancelToken: cancelToken,
        fetchStrategy: fetchStrategy,
        options: Options(
          responseType: ResponseType.bytes,
          headers: headers,
        ),
        onReceiveProgress: onReceiveProgress,
      );

      if (response == null || response.data == null) {
        throw StateError('Failed to load $url: Empty response');
      }

      final bytes = Uint8List.fromList(response.data!);
      if (bytes.lengthInBytes == 0) {
        throw StateError('NetworkImage is an empty file: $resolved');
      }

      return bytes;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        _print('User canceled request $url.', printError);
        throw StateError('User canceled request $url.');
      } else {
        _print('Failed to load $url: $e', printError);
        rethrow;
      }
    } catch (e) {
      _print('Failed to fetch $url: $e', printError);
      rethrow;
    }
  }

  static void _print(String message, bool printError) {
    if (printError && kDebugMode) {
      debugPrint('[ImageFetcher] $message');
    }
  }
}
