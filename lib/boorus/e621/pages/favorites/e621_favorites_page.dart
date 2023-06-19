// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/e621/e621_provider.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/widgets/e621_infinite_post_list.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';

class E621FavoritesPage extends ConsumerWidget {
  const E621FavoritesPage({
    super.key,
    required this.username,
  });

  static Widget of(
    BuildContext context, {
    required String username,
  }) =>
      E621Provider(
        builder: (_) => CustomContextMenuOverlay(
          child: E621FavoritesPage(username: username),
        ),
      );

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PostScope(
      fetcher: (page) => ref
          .read(e621PostRepoProvider)
          .getPosts('fav:${username.replaceAll(' ', '_')}', page),
      builder: (context, controller, errors) => E621InfinitePostList(
        errors: errors,
        controller: controller,
        sliverHeaderBuilder: (context) => [
          SliverAppBar(
            title: const Text('profile.favorites').tr(),
            floating: true,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: context.theme.scaffoldBackgroundColor,
          ),
          const SliverSizedBox(height: 5),
        ],
      ),
    );
  }
}
