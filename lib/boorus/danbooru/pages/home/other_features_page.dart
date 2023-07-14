// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/pages/home/side_menu_tile.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/foundation/i18n.dart';

class OtherFeaturesPage extends ConsumerWidget {
  const OtherFeaturesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: DanbooruOtherFeaturesWidget(),
        ),
      ),
    );
  }
}

class DanbooruOtherFeaturesWidget extends ConsumerWidget {
  const DanbooruOtherFeaturesWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final authState = ref.watch(authenticationProvider);
    // Only used to force rebuild when language changes
    ref.watch(settingsProvider.select((value) => value.language));
    return Column(
      children: [
        SideMenuTile(
          icon: const Icon(Icons.photo_album_outlined),
          title: const Text('Pools'),
          onTap: () {
            goToPoolPage(context, ref);
          },
        ),
        SideMenuTile(
          icon: const Icon(Icons.forum_outlined),
          title: const Text('forum.forum').tr(),
          onTap: () {
            goToForumPage(context);
          },
        ),
        if (authState.isAuthenticated) ...[
          SideMenuTile(
            icon: const Icon(Icons.favorite_outline),
            title: Text('profile.favorites'.tr()),
            onTap: () {
              goToFavoritesPage(context, booruConfig.login);
            },
          ),
          SideMenuTile(
            icon: const Icon(Icons.collections),
            title: const Text('favorite_groups.favorite_groups').tr(),
            onTap: () {
              goToFavoriteGroupPage(context);
            },
          ),
          SideMenuTile(
            icon: const Icon(Icons.search),
            title: const Text('saved_search.saved_search').tr(),
            onTap: () {
              goToSavedSearchPage(context, booruConfig.login);
            },
          ),
          SideMenuTile(
            icon: const FaIcon(FontAwesomeIcons.ban, size: 20),
            title: const Text(
              'blacklisted_tags.blacklisted_tags',
            ).tr(),
            onTap: () {
              goToBlacklistedTagPage(context);
            },
          ),
        ]
      ],
    );
  }
}
