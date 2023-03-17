// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/user_booru_repository.dart';
import 'package:boorusama/common/utils.dart';
import 'user_booru.dart';
import 'user_booru_credential.dart';

class HiveUserBooruRepository implements UserBooruRepository {
  HiveUserBooruRepository({
    required this.box,
  });
  final Box<String> box;

  @override
  Future<UserBooru?> add(UserBooruCredential credential) async {
    final json = credential.toJson();
    final jsonString = jsonEncode(json);
    final id = await box.add(jsonString);

    return convertToUserBooru(
      id: id,
      credential: credential,
    );
  }

  @override
  Future<void> remove(UserBooru userBooru) async {
    await box.delete(userBooru.id);
  }

  @override
  Future<List<UserBooru>> getAll() async {
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
