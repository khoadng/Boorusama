// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    super.key,
    required this.username,
  });

  static Widget of(
    BuildContext context, {
    required String username,
  }) {
    return DanbooruProvider.of(
      context,
      builder: (dContext) {
        return CustomContextMenuOverlay(
          child: FavoritesPage(username: username),
        );
      },
    );
  }

  final String username;

  @override
  Widget build(BuildContext context) {
    return DanbooruPostScope(
      fetcher: (page) => context
          .read<DanbooruPostRepository>()
          .getPosts('ordfav:$username', page),
      builder: (context, controller, errors) => DanbooruInfinitePostList(
        errors: errors,
        controller: controller,
        sliverHeaderBuilder: (context) => [
          SliverAppBar(
            title: const Text('profile.favorites').tr(),
            floating: true,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 5,
            ),
          ),
        ],
      ),
    );
  }
}
