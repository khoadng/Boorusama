// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/boorus/providers.dart';
import 'package:boorusama/core/configs/current.dart';
import '../../post/post.dart';
import 'post_share_state.dart';

final postShareProvider = NotifierProvider.autoDispose
    .family<PostShareNotifier, PostShareState, Post>(
  PostShareNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
    booruFactoryProvider,
  ],
);

class PostShareNotifier
    extends AutoDisposeFamilyNotifier<PostShareState, Post> {
  @override
  PostShareState build(Post arg) {
    final config = ref.read(currentBooruConfigProvider);
    final booruLink = arg.getLink(config.url);

    return PostShareState(
      booruLink: booruLink,
      sourceLink: arg.source,
    );
  }

  void updateInformation(Post post) {
    final config = ref.read(currentBooruConfigProvider);
    final booruLink = arg.getLink(config.url);

    state = state.copyWith(
      booruLink: booruLink,
      sourceLink: arg.source,
    );
  }
}
