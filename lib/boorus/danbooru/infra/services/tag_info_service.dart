// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';

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
      final metatags = <String>[...json['metatags']];
      final freeMetatags = <String>{...json['free_metatags']};
      final defaultBlacklistedTags = json['default_blacklisted_tags'];
      return TagInfoService(
        metatags: metatags
            .map((t) => Metatag(
                  name: t,
                  description: '',
                  example: '',
                  isFree: freeMetatags.contains(t),
                ))
            .toList(),
        defaultBlacklistedTags: [...defaultBlacklistedTags],
      );
    } catch (e) {
      return const TagInfoService(
        metatags: [],
        defaultBlacklistedTags: [],
      );
    }
  }

  final List<Metatag> metatags;
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

  final List<Metatag> metatags;
  final List<String> defaultBlacklistedTags;
}
