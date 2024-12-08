// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin DanbooruClientDmails {
  Dio get dio;

  Future<List<DmailDto>> getDmails({
    DmailFolderType? folder,
    int? limit,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/dmails.json',
      queryParameters: {
        if (folder != null) 'search[folder]': folder.name,
        if (limit != null) 'limit': limit,
      },
      cancelToken: cancelToken,
    );

    return (response.data as List)
        .map((item) => DmailDto.fromJson(item))
        .toList();
  }

  Future<void> _markDmail({
    required int id,
    bool isRead = false,
    CancelToken? cancelToken,
  }) async {
    await dio.put(
      '/dmails/$id.json',
      cancelToken: cancelToken,
      data: {
        'dmail[is_read]': isRead,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
  }

  Future<void> markDmailAsRead({
    required int id,
    CancelToken? cancelToken,
  }) async {
    await _markDmail(
      id: id,
      isRead: true,
      cancelToken: cancelToken,
    );
  }

  Future<void> markDmailAsUnread({
    required int id,
    CancelToken? cancelToken,
  }) async {
    await _markDmail(
      id: id,
      cancelToken: cancelToken,
    );
  }
}
