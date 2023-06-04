// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/pages/search/metatags_section.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/danbooru/feat/tags/tags.dart';

class DanbooruMetatagsSection extends ConsumerWidget {
  const DanbooruMetatagsSection({
    super.key,
    this.onOptionTap,
    required this.metatags,
  });

  final ValueChanged<String>? onOptionTap;
  final List<Metatag> metatags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booru = ref.watch(currentBooruProvider);
    final userMetatags = ref.watch(danbooruUserMetatagsProvider);

    return MetatagsSection(
      onOptionTap: onOptionTap,
      metatags: metatags,
      userMetatags: () => userMetatags,
      onHelpRequest: () {
        launchExternalUrl(
          Uri.parse(booru.cheatsheet),
          mode: LaunchMode.platformDefault,
        );
      },
      onUserMetatagDeleted: (tag) =>
          ref.read(danbooruUserMetatagsProvider.notifier).delete(tag),
      onUserMetatagAdded: (tag) =>
          ref.read(danbooruUserMetatagsProvider.notifier).add(tag.name),
    );
  }
}
