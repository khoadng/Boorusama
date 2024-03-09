// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';

const String _assetUrl = 'assets/tagdef.json';

class TagInfoService {
  const TagInfoService({
    required this.metatags,
    required this.defaultBlacklistedTags,
    required this.r18Tags,
  });

  static Future<TagInfoService> create() async {
    try {
      final data = await rootBundle.loadString(_assetUrl);
      final Map<String, dynamic> json = jsonDecode(data);
      final metatags = <String>[...json['metatags']];
      final freeMetatags = <String>{...json['free_metatags']};
      final defaultBlacklistedTags = json['default_blacklisted_tags'];
      final r18Tags = <String>{...json['r18_tags']};

      return TagInfoService(
        metatags: metatags
            .map((t) => Metatag(
                  name: t,
                  description: '',
                  example: '',
                  isFree: freeMetatags.contains(t),
                ))
            .toSet(),
        defaultBlacklistedTags: {...defaultBlacklistedTags},
        r18Tags: r18Tags,
      );
    } catch (e) {
      return const TagInfoService(
        metatags: {},
        defaultBlacklistedTags: {},
        r18Tags: {},
      );
    }
  }

  final Set<Metatag> metatags;
  final Set<String> defaultBlacklistedTags;
  final Set<String> r18Tags;

  TagInfo getInfo() {
    return TagInfo(
      metatags: metatags,
      defaultBlacklistedTags: defaultBlacklistedTags,
      r18Tags: r18Tags,
    );
  }
}

class TagInfo {
  const TagInfo({
    required this.metatags,
    required this.defaultBlacklistedTags,
    required this.r18Tags,
  });

  final Set<Metatag> metatags;
  final Set<String> defaultBlacklistedTags;
  final Set<String> r18Tags;
}
