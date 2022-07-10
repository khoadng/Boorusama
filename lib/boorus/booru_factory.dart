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
  }) {
    try {
      if (isSafeMode) {
        return _boorus[BooruType.safebooru]!;
      } else {
        return _boorus[BooruType.danbooru]!;
      }
    } catch (e) {
      return safebooru();
    }
  }
}

const String _assetUrl = 'assets/boorus.json';

Future<List<BooruData>> loadBooruList() async {
  try {
    final data = await rootBundle.loadString(_assetUrl);
    final boorus =
        (jsonDecode(data) as List).map((e) => BooruData.fromJson(e)).toList();

    return boorus;
  } catch (e) {
    return [];
  }
}
