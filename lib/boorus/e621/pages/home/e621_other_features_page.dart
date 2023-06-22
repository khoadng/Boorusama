// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/router.dart';
import 'package:boorusama/foundation/i18n.dart';

class E621OtherFeaturesPage extends ConsumerWidget {
  const E621OtherFeaturesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: Text('profile.favorites'.tr()),
                onTap: () => goToE621FavoritesPage(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
