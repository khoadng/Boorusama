// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';

class OtherFeaturesPage extends StatelessWidget {
  const OtherFeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userBooru =
        context.select((CurrentBooruBloc bloc) => bloc.state.userBooru);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: Text('profile.favorites'.tr()),
                onTap: () {
                  goToFavoritesPage(context, userBooru!.login);
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
                  goToSavedSearchPage(context, userBooru!.login);
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
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('download.bulk_download').tr(),
                onTap: () {
                  goToBulkDownloadPage(context, null);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
