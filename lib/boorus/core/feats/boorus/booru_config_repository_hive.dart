// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/utils/utils.dart';

class HiveBooruConfigRepository implements BooruConfigRepository {
  HiveBooruConfigRepository({
    required this.box,
  });
  final Box<String> box;

  static String defaultValue(BooruFactory factory) =>
      jsonEncode(BooruConfigData.anonymous(
        booru: BooruType.safebooru,
        name: 'Default booru',
        filter: BooruConfigRatingFilter.none,
        url: factory.from(type: BooruType.safebooru).url,
      ));

  @override
  Future<BooruConfig?> add(BooruConfigData booruConfigData) async {
    final json = booruConfigData.toJson();
    final jsonString = jsonEncode(json);
    final id = await box.add(jsonString);

    return convertToBooruConfig(
      id: id,
      booruConfigData: booruConfigData,
    );
  }

  @override
  Future<void> remove(BooruConfig booruConfig) async {
    await box.delete(booruConfig.id);
  }

  @override
  Future<List<BooruConfig>> getAll() async {
    return box.keys
        .map((e) {
          final jsonString = box.get(e);
          if (jsonString == null) return null;
          final json = jsonDecode(jsonString);
          final booruConfigData = BooruConfigData.fromJson(json);

          return convertToBooruConfig(
            id: castOrNull<int>(e),
            booruConfigData: booruConfigData,
          );
        })
        .whereNotNull()
        .toList();
  }

  @override
  Future<BooruConfig?> update(int id, BooruConfigData booruConfigData) async {
    final json = booruConfigData.toJson();
    final jsonString = jsonEncode(json);

    try {
      await box.put(id, jsonString);

      return convertToBooruConfig(
        id: id,
        booruConfigData: booruConfigData,
      );
    } catch (e) {
      return null;
    }
  }
}
