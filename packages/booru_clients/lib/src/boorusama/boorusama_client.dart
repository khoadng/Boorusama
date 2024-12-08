// Package imports:
import 'package:dio/dio.dart';

const _kAnnouncementUrl =
    'https://raw.githubusercontent.com/khoadng/boorusama-static/master/announcement.html';

class BoorusamaClient {
  final Dio _dio = Dio();

  Future<String> getAnnouncement() async {
    final response = await _dio.get(_kAnnouncementUrl);

    return response.data;
  }
}
