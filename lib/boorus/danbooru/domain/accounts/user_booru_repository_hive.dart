import 'package:boorusama/boorus/danbooru/domain/accounts/user_booru_repository.dart';
import 'package:boorusama/common/utils.dart';
import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

import 'user_booru.dart';
import 'user_booru_credential.dart';

class HiveUserBooruRepository implements UserBooruRepository {
  HiveUserBooruRepository({
    required this.box,
  });
  final Box<UserBooruCredential> box;

  @override
  Future<UserBooru?> add(UserBooruCredential credential) async {
    final id = await box.add(credential);

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
        .map((e) => convertToUserBooru(
              id: castOrNull<int>(e),
              credential: box.get(e),
            ))
        .whereNotNull()
        .toList();
  }
}
