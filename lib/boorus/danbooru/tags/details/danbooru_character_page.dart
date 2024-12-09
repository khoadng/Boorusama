// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/tags/details/widgets.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import '../../wikis/providers.dart';
import 'danbooru_tag_details_page.dart';

class DanbooruCharacterPage extends ConsumerWidget {
  const DanbooruCharacterPage({
    super.key,
    required this.characterName,
  });

  final String characterName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomContextMenuOverlay(
      child: DanbooruTagDetailsPage(
        tagName: characterName,
        otherNames: switch (ref.watch(danbooruWikiProvider(characterName))) {
          WikiStateLoading _ => const TagOtherNames(otherNames: null),
          final WikiStateLoaded s =>
            TagOtherNames(otherNames: s.wiki.otherNames),
          WikiStateError _ => const SizedBox.shrink(),
          WikiStateNotFound _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
