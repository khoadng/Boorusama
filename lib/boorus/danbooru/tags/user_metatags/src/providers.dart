// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import 'user_metatag_repository.dart';

final danbooruUserMetatagRepoProvider = FutureProvider<UserMetatagRepository>((
  ref,
) async {
  Box<String> userMetatagBox;
  if (await Hive.boxExists('user_metatags')) {
    userMetatagBox = await Hive.openBox<String>('user_metatags');
  } else {
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

  return userMetatagRepo;
});
