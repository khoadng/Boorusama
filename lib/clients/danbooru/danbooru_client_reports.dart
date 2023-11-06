// Dart imports:
import 'dart:isolate';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

enum ReportPeriod {
  day,
  week,
  month,
  year,
}

mixin DanbooruClientReports {
  Dio get dio;

  String _formatDate(DateTime date) => '${date.year}-${date.month}-${date.day}';

  Future<List<ReportDataPointDto>> getPostReport({
    required List<String> tags,
    required ReportPeriod period,
    required DateTime from,
    required DateTime to,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/reports/posts.json',
      queryParameters: {
        'search[tags]': tags.join(' '),
        'search[period]': period.name,
        'search[from]': _formatDate(from),
        'search[to]': _formatDate(to),
      },
      cancelToken: cancelToken,
    );

    return Isolate.run(() => (response.data as List)
        .map((item) => ReportDataPointDto.fromJson(item))
        .toList());
  }
}
