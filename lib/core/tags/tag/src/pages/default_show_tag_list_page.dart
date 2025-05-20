// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../blacklists/providers.dart';
import '../../../../configs/ref.dart';
import '../../../favorites/providers.dart';
import '../tag.dart';
import '../tag_display.dart';
import 'show_tag_list_page.dart';

class DefaultShowTagListPage extends ConsumerWidget {
  const DefaultShowTagListPage({
    required this.tags,
    super.key,
  });

  final List<Tag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalNotifier = ref.watch(globalBlacklistedTagsProvider.notifier);
    final favoriteNotifier = ref.watch(favoriteTagsProvider.notifier);
    final auth = ref.watchConfigAuth;

    return ShowTagListPage(
      tags: tags,
      auth: auth,
      onAddToGlobalBlacklist: (tag) {
        globalNotifier.addTagWithToast(
          context,
          tag.rawName,
        );
      },
      onAddToFavoriteTags: (tag) {
        favoriteNotifier.add(
          tag.rawName,
        );
      },
    );
  }
}
