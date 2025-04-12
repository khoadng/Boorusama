// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../post/post.dart';
import 'post_share_state.dart';

final postShareProvider = NotifierProvider.autoDispose
    .family<PostShareNotifier, PostShareState, Post>(
  PostShareNotifier.new,
);

class PostShareNotifier
    extends AutoDisposeFamilyNotifier<PostShareState, Post> {
  @override
  PostShareState build(Post arg) {
    final postLinkGenerator = ref.watch(currentPostLinkGeneratorProvider);

    final booruLink = postLinkGenerator?.getLink(arg);

    return PostShareState(
      booruLink: booruLink ?? '',
      sourceLink: arg.source,
    );
  }

  void updateInformation(Post post) {
    final booruLink = ref.read(currentPostLinkGeneratorProvider)?.getLink(post);

    state = state.copyWith(
      booruLink: booruLink,
      sourceLink: arg.source,
    );
  }
}
