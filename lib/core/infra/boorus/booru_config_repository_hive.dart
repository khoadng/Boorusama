// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/utils/utils.dart';

class HiveBooruConfigRepository implements BooruConfigRepository {
  HiveBooruConfigRepository({
    required this.box,
  });
  final Box<String> box;

  static String defaultValue() => jsonEncode(BooruConfigData.anonymous(
        booru: BooruType.safebooru,
        name: 'My config',
        filter: BooruConfigRatingFilter.none,
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
}
