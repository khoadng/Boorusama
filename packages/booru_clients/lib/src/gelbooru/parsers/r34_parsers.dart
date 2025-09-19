import 'package:dio/dio.dart';

import '../types/post_v2_dto.dart';
import 'common.dart';

PostV2Dto? parseR34PostHtml(
  Response response,
  Map<String, dynamic> context,
) => parseDefaultPostHtml(
  response,
  context,
  imageExtractor: DefaultHtmlImageExtractor(
    hashRegexPattern: r'/([a-f0-9]{40})\.[^/]*$',
    directoryRegexPattern: r'//images/(\d+)/',
    jsDirRegexPattern: r"'dir':\s*(\d+)",
    sampleHostTransform: (url) => switch (Uri.tryParse(url)) {
      Uri(host: final host) when !host.contains('wimg.') =>
        Uri.tryParse(url)?.replace(host: 'wimg.$host').toString() ?? url,
      _ => url,
    },
  ),
);
