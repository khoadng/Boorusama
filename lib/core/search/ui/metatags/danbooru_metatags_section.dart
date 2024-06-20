// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/search/ui/metatags_section.dart';
import 'package:boorusama/core/utils.dart';

class DanbooruMetatagsSection extends ConsumerWidget {
  const DanbooruMetatagsSection({
    super.key,
    this.onOptionTap,
  });

  final ValueChanged<String>? onOptionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfig;
    final booru = booruConfig.createBooruFrom(ref.watch(booruFactoryProvider));
    final userMetatags = ref.watch(danbooruUserMetatagsProvider);
    final metatags = ref.watch(metatagsProvider);
    final cheatSheet = booru?.cheetsheet(booruConfig.url);
    final notifier = ref.watch(danbooruUserMetatagsProvider.notifier);

    return MetatagsSection(
      onOptionTap: onOptionTap,
      metatags: metatags.toList(),
      userMetatags: () => userMetatags,
      onHelpRequest: cheatSheet != null && !booruConfig.hasStrictSFW
          ? () {
              launchExternalUrl(
                Uri.parse(cheatSheet),
                mode: LaunchMode.platformDefault,
              );
            }
          : null,
      onUserMetatagDeleted: (tag) => notifier.delete(tag),
      onUserMetatagAdded: (tag) => notifier.add(tag.name),
    );
  }
}
