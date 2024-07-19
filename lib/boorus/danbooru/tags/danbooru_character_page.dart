// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/tags/danbooru_tag_details_page.dart';
import 'package:boorusama/boorus/danbooru/wikis/wikis.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';

class DanbooruCharacterPage extends ConsumerWidget {
  const DanbooruCharacterPage({
    super.key,
    required this.characterName,
    required this.backgroundImageUrl,
  });

  final String characterName;
  final String backgroundImageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomContextMenuOverlay(
      child: DanbooruTagDetailsPage(
        tagName: characterName,
        otherNamesBuilder: (context) =>
            switch (ref.watch(danbooruWikiProvider(characterName))) {
          WikiStateLoading _ => const TagOtherNames(otherNames: null),
          WikiStateLoaded s => TagOtherNames(otherNames: s.wiki.otherNames),
          WikiStateError _ => const SizedBox.shrink(),
          WikiStateNotFound _ => const SizedBox.shrink(),
        },
        backgroundImageUrl: backgroundImageUrl,
      ),
    );
  }
}
