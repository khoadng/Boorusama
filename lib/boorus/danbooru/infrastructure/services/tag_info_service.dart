// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

const String _assetUrl = 'assets/tagdef.json';

class TagInfoService {
  const TagInfoService({
    required this.metatags,
  });

  static Future<TagInfoService> create() async {
    try {
      final data = await rootBundle.loadString(_assetUrl);
      final Map<String, dynamic> json = jsonDecode(data);
      final metatags = json['metatags'];
      return TagInfoService(metatags: [...metatags]);
    } catch (e) {
      return const TagInfoService(metatags: []);
    }
  }

  final List<String> metatags;

  TagInfo getInfo() {
    return TagInfo(metatags: metatags);
  }
}

class TagInfo {
  const TagInfo({
    required this.metatags,
  });

  final List<String> metatags;
}
