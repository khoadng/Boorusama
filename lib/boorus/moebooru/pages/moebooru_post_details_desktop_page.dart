// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/router.dart';
import 'widgets/moebooru_comment_section.dart';
import 'widgets/moebooru_information_section.dart';

class MoebooruPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const MoebooruPostDetailsDesktopPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MoebooruPostDetailsDesktopPageState();
}

class _MoebooruPostDetailsDesktopPageState
    extends ConsumerState<MoebooruPostDetailsDesktopPage> {
  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;

    final data = PostDetails.of<MoebooruPost>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageDesktopScaffold(
      controller: controller,
      posts: posts,
      imageUrlBuilder: defaultPostImageUrlBuilder(ref),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
      infoBuilder: (context, post) => MoebooruInformationSection(
        post: post,
        tags: ref.watch(tagsProvider(config)),
      ),
      tagListBuilder: (context, post) => TagsTile(
        post: post,
        tags: ref.watch(tagsProvider(config)),
        onTagTap: (tag) => goToSearchPage(
          context,
          tag: tag.rawName,
        ),
      ),
      commentBuilder: (context, post) => MoebooruCommentSection(
        post: post,
      ),
    );
  }
}
