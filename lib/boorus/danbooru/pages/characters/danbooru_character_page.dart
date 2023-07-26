// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/wikis/wikis.dart';
import 'package:boorusama/boorus/danbooru/widgets/danbooru_tag_details_page.dart';

class DanbooruCharacterPage extends ConsumerWidget {
  const DanbooruCharacterPage({
    super.key,
    required this.characterName,
    required this.backgroundImageUrl,
  });

  final String characterName;
  final String backgroundImageUrl;

  static Widget of(BuildContext context, String tag) {
    return DanbooruProvider(
      builder: (_) => CustomContextMenuOverlay(
        child: DanbooruCharacterPage(
          characterName: tag,
          backgroundImageUrl: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DanbooruTagDetailsPage(
      tagName: characterName,
      otherNamesBuilder: (context) =>
          switch (ref.watch(danbooruWikiProvider(characterName))) {
        WikiStateLoading _ => const TagOtherNames(otherNames: null),
        WikiStateLoaded s => TagOtherNames(otherNames: s.wiki.otherNames),
        WikiStateError _ => const SizedBox.shrink(),
        WikiStateNotFound _ => const SizedBox.shrink(),
      },
      backgroundImageUrl: backgroundImageUrl,
    );
  }
}
