// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/tags/details/widgets.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../wikis/providers.dart';
import 'danbooru_tag_details_page.dart';

class DanbooruCharacterPage extends ConsumerWidget {
  const DanbooruCharacterPage({
    required this.characterName,
    super.key,
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
