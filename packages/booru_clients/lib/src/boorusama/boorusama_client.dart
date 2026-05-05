// Package imports:
import 'package:dio/dio.dart';

import 'announcement.dart';

const _kLegacyAnnouncementUrl =
    'https://raw.githubusercontent.com/khoadng/boorusama-static/master/announcement.html';
const _kAnnouncementBaseUrl = 'https://api.degenk.com/announcements/';

class BoorusamaClient {
  BoorusamaClient({
    Dio? dio,
    String? legacyAnnouncementUrl,
    String? announcementBaseUrl,
  }) : _dio = dio ?? Dio(),
       _legacyAnnouncementUrl =
           legacyAnnouncementUrl ?? _kLegacyAnnouncementUrl,
       _announcementBaseUrl =
           (announcementBaseUrl ?? _kAnnouncementBaseUrl).endsWith('/')
           ? announcementBaseUrl ?? _kAnnouncementBaseUrl
           : '${announcementBaseUrl ?? _kAnnouncementBaseUrl}/';

  final Dio _dio;
  final String _legacyAnnouncementUrl;
  final String _announcementBaseUrl;

  Future<String> getLegacyAnnouncement() async {
    final response = await _dio.get(_legacyAnnouncementUrl);

    return response.data?.toString() ?? '';
  }

  Future<BoorusamaAnnouncementIndex> getAnnouncementIndex() async {
    final response = await _dio.getUri(_announcementUri('index.json'));

    return BoorusamaAnnouncementIndex.fromJson(
      boorusamaJsonMapFromResponseData(response.data),
    );
  }

  Future<BoorusamaAnnouncementFile> getAnnouncementFile(String path) async {
    final response = await _dio.getUri(_announcementUri(path));

    return BoorusamaAnnouncementFile.fromJson(
      boorusamaJsonMapFromResponseData(response.data),
    );
  }

  Uri _announcementUri(String path) {
    final uri = Uri.parse(path);
    if (uri.hasScheme || uri.hasAuthority) {
      throw ArgumentError.value(
        path,
        'path',
        'Announcement file paths must be relative.',
      );
    }

    return Uri.parse(_announcementBaseUrl).resolve(path);
  }
}
