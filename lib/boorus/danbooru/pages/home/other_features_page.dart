// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/foundation/i18n.dart';

class OtherFeaturesPage extends ConsumerWidget {
  const OtherFeaturesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final authState = ref.watch(authenticationProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_album_outlined),
                title: const Text('Pools'),
                onTap: () {
                  goToPoolPage(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.forum_outlined),
                title: const Text('Forum'),
                onTap: () {
                  goToForumPage(context);
                },
              ),
              if (authState.isAuthenticated) ...[
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: Text('profile.favorites'.tr()),
                  onTap: () {
                    goToFavoritesPage(context, booruConfig.login);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.collections),
                  title: const Text('Favorite groups'),
                  onTap: () {
                    goToFavoriteGroupPage(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text('Saved search'),
                  onTap: () {
                    goToSavedSearchPage(context, booruConfig.login);
                  },
                ),
                ListTile(
                  leading: const FaIcon(FontAwesomeIcons.ban, size: 20),
                  title: const Text(
                    'blacklisted_tags.blacklisted_tags',
                  ).tr(),
                  onTap: () {
                    goToBlacklistedTagPage(context);
                  },
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
