// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import 'user_metatag_repository.dart';

final danbooruUserMetatagRepoProvider = Provider<UserMetatagRepository>((ref) {
  throw UnimplementedError();
});

Future<Override> createUserMetatagRepoOverride({
  required BootLogger bootLogger,
}) async {
  Box<String> userMetatagBox;
  bootLogger.l('Initialize user metatag box');
  if (await Hive.boxExists('user_metatags')) {
    bootLogger.l('Open user metatag box');
    userMetatagBox = await Hive.openBox<String>('user_metatags');
  } else {
    bootLogger.l('Create user metatag box');
    userMetatagBox = await Hive.openBox<String>('user_metatags');
    for (final e in [
      'age',
      'rating',
      'order',
      'score',
      'id',
      'user',
    ]) {
      await userMetatagBox.put(e, e);
    }
  }

  final userMetatagRepo = UserMetatagRepository(box: userMetatagBox);

  return danbooruUserMetatagRepoProvider.overrideWithValue(userMetatagRepo);
}
