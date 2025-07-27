// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config/types.dart';
import '../../post/post.dart';
import '../../post/providers.dart';
import 'post_share_state.dart';

typedef PostShareParams = (BooruConfigAuth config, Post post);

final postShareProvider = NotifierProvider.autoDispose
    .family<PostShareNotifier, PostShareState, PostShareParams>(
      PostShareNotifier.new,
    );

class PostShareNotifier
    extends AutoDisposeFamilyNotifier<PostShareState, PostShareParams> {
  @override
  PostShareState build(PostShareParams arg) {
    final (config, post) = arg;
    final postLinkGenerator = ref.watch(
      postLinkGeneratorProvider(config),
    );

    final booruLink = postLinkGenerator.getLink(post);

    return PostShareState(
      booruLink: booruLink,
      sourceLink: post.source,
    );
  }

  void updateInformation(Post post) {
    final (config, currPost) = arg;

    final booruLink = ref.read(postLinkGeneratorProvider(config)).getLink(post);

    state = state.copyWith(
      booruLink: booruLink,
      sourceLink: post.source,
    );
  }
}
