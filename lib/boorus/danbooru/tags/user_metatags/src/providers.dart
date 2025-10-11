// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/tags/configs/providers.dart';
import '../../../../../core/tags/metatag/types.dart';
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

final metatagsProvider = Provider<Set<Metatag>>(
  (ref) => ref.watch(tagInfoProvider.select((v) => v.metatags)),
  dependencies: [tagInfoProvider],
);

final danbooruMetatagExtractorProvider =
    Provider.family<DefaultMetatagExtractor, BooruConfigAuth>(
      (ref, config) {
        final tagInfo = ref.watch(tagInfoProvider);
        return DefaultMetatagExtractor(
          metatags: tagInfo.metatags,
        );
      },
      dependencies: [tagInfoProvider],
    );
