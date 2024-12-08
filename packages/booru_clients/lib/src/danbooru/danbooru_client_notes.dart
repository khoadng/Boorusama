// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin DanbooruClientNotes {
  Dio get dio;

  Future<List<NoteDto>> getNotes({
    required int postId,
    int limit = 200,
    int? page,
  }) async {
    final response = await dio.get(
      '/notes.json',
      queryParameters: {
        'search[post_id]': postId,
        'limit': limit,
        if (page != null) 'page': page,
      },
    );

    return (response.data as List)
        .map((item) => NoteDto.fromJson(item))
        .toList();
  }

  Future<NoteDto> createNote({
    required int postId,
    required int x,
    required int y,
    required int width,
    required int height,
    required String body,
  }) async {
    final response = await dio.post(
      '/notes.json',
      data: {
        'note[post_id]': postId,
        'note[x]': x,
        'note[y]': y,
        'note[width]': width,
        'note[height]': height,
        'note[body]': body,
      },
      options: Options(
        headers: dio.options.headers,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return NoteDto.fromJson(response.data);
  }
}
