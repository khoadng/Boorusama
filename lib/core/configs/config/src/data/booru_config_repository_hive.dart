// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:foundation/foundation.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../../../boorus/booru/booru.dart';
import '../../../../downloads/filename/types.dart';
import '../types/booru_config.dart';
import '../types/booru_config_data.dart';
import '../types/booru_config_repository.dart';
import 'booru_config_converter.dart';

class HiveBooruConfigRepository implements BooruConfigRepository {
  HiveBooruConfigRepository({
    required this.box,
  });
  final Box<String> box;

  static String defaultValue() => jsonEncode(
    BooruConfigData.anonymous(
      booru: BooruType.danbooru,
      booruHint: BooruType.danbooru,
      name: 'Default profile',
      filter: BooruConfigRatingFilter.none,
      url: 'https://safebooru.donmai.us/',
      customDownloadFileNameFormat: kBoorusamaCustomDownloadFileNameFormat,
      customBulkDownloadFileNameFormat:
          kBoorusamaBulkDownloadCustomFileNameFormat,
      imageDetaisQuality: null,
    ),
  );

  @override
  Future<BooruConfig?> add(BooruConfigData booruConfigData) async {
    final json = booruConfigData.toJson();
    final jsonString = jsonEncode(json);
    final id = await box.add(jsonString);

    return booruConfigData.toBooruConfig(
      id: id,
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

          return booruConfigData.toBooruConfig(
            id: castOrNull<int>(e),
          );
        })
        .nonNulls
        .toList();
  }

  @override
  Future<BooruConfig?> update(int id, BooruConfigData booruConfigData) async {
    final json = booruConfigData.toJson();
    final jsonString = jsonEncode(json);

    try {
      await box.put(id, jsonString);

      return booruConfigData.toBooruConfig(
        id: id,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clear() async {
    await box.clear();
  }

  @override
  Future<List<BooruConfig>> addAll(List<BooruConfig> booruConfigs) async {
    final configs = <BooruConfig>[];

    for (final booruConfig in booruConfigs) {
      final data = booruConfig.toBooruConfigData();
      final json = data.toJson();
      final jsonString = jsonEncode(json);
      await box.put(booruConfig.id, jsonString);

      configs.add(
        data.toBooruConfig(
          id: booruConfig.id,
        )!,
      );
    }

    return configs;
  }
}
