// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

const String _assetUrl = 'assets/tagdef.json';

class TagInfoService {
  const TagInfoService({
    required this.metatags,
    required this.defaultBlacklistedTags,
  });

  static Future<TagInfoService> create() async {
    try {
      final data = await rootBundle.loadString(_assetUrl);
      final Map<String, dynamic> json = jsonDecode(data);
      final metatags = json['metatags'];
      final defaultBlacklistedTags = json['default_blacklisted_tags'];
      return TagInfoService(
        metatags: [...metatags],
        defaultBlacklistedTags: [...defaultBlacklistedTags],
      );
    } catch (e) {
      return const TagInfoService(
        metatags: [],
        defaultBlacklistedTags: [],
      );
    }
  }

  final List<String> metatags;
  final List<String> defaultBlacklistedTags;

  TagInfo getInfo() {
    return TagInfo(
      metatags: metatags,
      defaultBlacklistedTags: defaultBlacklistedTags,
    );
  }
}

class TagInfo {
  const TagInfo({
    required this.metatags,
    required this.defaultBlacklistedTags,
  });

  final List<String> metatags;
  final List<String> defaultBlacklistedTags;
}
