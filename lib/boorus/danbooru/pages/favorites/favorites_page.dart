// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({
    super.key,
    required this.username,
  });

  static Widget of(
    BuildContext context, {
    required String username,
  }) =>
      DanbooruProvider(
        builder: (_) => CustomContextMenuOverlay(
          child: FavoritesPage(username: username),
        ),
      );

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DanbooruPostScope(
      fetcher: (page) =>
          ref.read(danbooruPostRepoProvider).getPosts('ordfav:$username', page),
      builder: (context, controller, errors) => DanbooruInfinitePostList(
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
