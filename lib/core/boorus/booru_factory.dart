// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/services.dart';

// Project imports:
import 'package:boorusama/utils/collection_utils.dart';
import 'booru.dart';

class BooruFactory {
  const BooruFactory._({
    required Map<BooruType, Booru> boorus,
    required this.booruData,
    required this.booruSaltData,
  }) : _boorus = boorus;

  factory BooruFactory.from(
    List<BooruData> booruData,
    List<BooruSaltData> booruSaltData,
  ) {
    final boorus = booruData.map(booruDataToBooru).toList();
    final boorusMap = {for (final b in boorus) b.booruType: b};

    return BooruFactory._(
      booruSaltData: booruSaltData,
      boorus: boorusMap,
      booruData: booruData,
    );
  }

  final List<BooruData> booruData;
  final List<BooruSaltData> booruSaltData;
  final Map<BooruType, Booru> _boorus;

  String getSalt(Booru booru) =>
      booruSaltData
          .firstOrNull((e) => stringToBooruType(e.booru) == booru.booruType)
          ?.salt ??
      '';

  Booru from({
    required BooruType type,
  }) {
    try {
      return _boorus[type]!;
    } catch (e) {
      return unknownBooru();
    }
  }
}

const String _assetUrl = 'assets/boorus.json';
const String _saltUrl = 'assets/booru_salts.json';

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

Future<List<BooruSaltData>> loadBooruSaltList() async {
  try {
    final data = await rootBundle.loadString(_saltUrl);

    return (jsonDecode(data) as List)
        .map((e) => BooruSaltData.fromJson(e))
        .toList();
  } catch (e) {
    return [];
  }
}
