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

  static String defaultValue() =>
      jsonEncode(UserBooruCredential.anonymous(booru: BooruType.safebooru));

  @override
  Future<BooruConfig?> add(UserBooruCredential credential) async {
    final json = credential.toJson();
    final jsonString = jsonEncode(json);
    final id = await box.add(jsonString);

    return convertToUserBooru(
      id: id,
      credential: credential,
    );
  }

  @override
  Future<void> remove(BooruConfig userBooru) async {
    await box.delete(userBooru.id);
  }

  @override
  Future<List<BooruConfig>> getAll() async {
    return box.keys
        .map((e) {
          final jsonString = box.get(e);
          if (jsonString == null) return null;
          final json = jsonDecode(jsonString);
          final credential = UserBooruCredential.fromJson(json);

          return convertToUserBooru(
            id: castOrNull<int>(e),
            credential: credential,
          );
        })
        .whereNotNull()
        .toList();
  }
}
