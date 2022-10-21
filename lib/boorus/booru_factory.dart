// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'booru.dart';

class BooruFactory {
  const BooruFactory({
    required Map<BooruType, Booru> boorus,
  }) : _boorus = boorus;

  factory BooruFactory.from(List<BooruData> booruData) {
    final boorus = booruData.map(booruDataToBooru).toList();
    final boorusMap = {for (final b in boorus) b.booruType: b};

    return BooruFactory(boorus: boorusMap);
  }

  final Map<BooruType, Booru> _boorus;

  Booru create({
    required bool isSafeMode,
  }) =>
      from(type: isSafeMode ? BooruType.safebooru : BooruType.danbooru);

  Booru from({
    required BooruType type,
  }) {
    try {
      return _boorus[type]!;
    } catch (e) {
      return safebooru();
    }
  }
}

const String _assetUrl = 'assets/boorus.json';

Future<List<BooruData>> loadBooruList() async {
  try {
    final data = await rootBundle.loadString(_assetUrl);

    return (jsonDecode(data) as List)
        .map((e) => BooruData.fromJson(e))
        .toList();
  } catch (e) {
    return [];
  }
}
