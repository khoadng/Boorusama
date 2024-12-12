// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../../../../core/boorus.dart';
import '../../../../../../core/boorus/providers.dart';
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/foundation/url_launcher.dart';
import '../../../../../../core/search/metatag_widgets.dart';
import '../../../../../../core/tags/metatag/providers.dart';
import '../../../../tags/user_metatags/providers.dart';

class DanbooruMetatagsSection extends ConsumerWidget {
  const DanbooruMetatagsSection({
    super.key,
    this.onOptionTap,
  });

  final ValueChanged<String>? onOptionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruConfig = ref.watchConfigAuth;
    final booru = booruConfig.createBooruFrom(ref.watch(booruFactoryProvider));
    final metatags = ref.watch(metatagsProvider);
    final cheatSheet = booru?.cheetsheet(booruConfig.url);
    final notifier = ref.watch(danbooruUserMetatagsProvider.notifier);

    return MetatagsSection(
      onOptionTap: onOptionTap,
      metatags: metatags.toList(),
      userMetatags: ref.watch(danbooruUserMetatagsProvider).maybeWhen(
            data: (tags) => tags,
            orElse: () => null,
          ),
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
