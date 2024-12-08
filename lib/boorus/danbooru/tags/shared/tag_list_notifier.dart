// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/posts/post/converter.dart';
import 'package:boorusama/boorus/danbooru/posts/post/danbooru_post.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/posts/rating.dart';
import 'package:boorusama/functional.dart';

final danbooruTagListProvider = NotifierProviderFamily<
    DanbooruTagListNotifier,
    IMap<int, DanbooruTagDetails>,
    BooruConfigAuth>(DanbooruTagListNotifier.new);

class DanbooruTagListNotifier
    extends FamilyNotifier<IMap<int, DanbooruTagDetails>, BooruConfigAuth> {
  @override
  IMap<int, DanbooruTagDetails> build(BooruConfigAuth arg) {
    return <int, DanbooruTagDetails>{}.lock;
  }

  Future<void> setTags(
    int postId, {
    List<String>? addedTags,
    List<String>? removedTags,
    Rating? rating,
  }) async {
    if (addedTags == null && removedTags == null && rating == null) {
      return;
    }
    final tags = [
      ...addedTags ?? <String>[],
      ...removedTags?.map((e) => '-$e') ?? <String>[],
      if (rating != null) 'rating:${rating.name}',
    ];

    final client = ref.read(danbooruClientProvider(arg));

    final post = await client
        .putTags(postId: postId, tags: tags)
        .then(postDtoToPostNoMetadata);

    ref.read(loggerProvider).logI(
        'Tag Edit',
        [
          if (addedTags != null && addedTags.isNotEmpty) 'Added: $addedTags',
          if (removedTags != null && removedTags.isNotEmpty)
            'Removed: $removedTags',
          if (rating != null) 'Rating changed: ${rating.name}',
        ].join(', '));

    state = state.add(postId, post);
  }

  void removeTags(List<int> postIds) {
    state = state.removeWhere((key, value) => postIds.contains(key));
  }
}
