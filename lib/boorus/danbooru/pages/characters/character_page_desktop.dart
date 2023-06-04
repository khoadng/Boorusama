// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/pages/tag_other_names.dart';
import 'package:boorusama/boorus/danbooru/feat/wikis/wikis.dart';
import 'package:boorusama/boorus/danbooru/pages/shared/tag_detail_page_desktop.dart';
import 'character_page.dart';

class CharacterPageDesktop extends ConsumerWidget {
  const CharacterPageDesktop({
    super.key,
    required this.characterName,
  });

  final String characterName;

  static Widget of(BuildContext context, String tag) {
    return provideCharacterPageDependencies(
      context,
      character: tag,
      page: CharacterPageDesktop(
        characterName: tag,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TagDetailPageDesktop(
      tagName: characterName,
      otherNamesBuilder: (context) =>
          switch (ref.watch(danbooruWikiProvider(characterName))) {
        WikiStateLoading _ => const TagOtherNames(otherNames: null),
        WikiStateLoaded s => TagOtherNames(otherNames: s.wiki.otherNames),
        WikiStateError _ => const SizedBox.shrink(),
        WikiStateNotFound _ => const SizedBox.shrink(),
      },
    );
  }
}
