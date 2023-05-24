// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/wikis.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_detail_page.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/tag_detail_page_desktop.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/tag_other_names.dart';

Widget provideCharacterPageDependencies(
  BuildContext context, {
  required String character,
  required Widget page,
}) =>
    DanbooruProvider(
      builder: (_) => CustomContextMenuOverlay(child: page),
    );

class CharacterPage extends ConsumerWidget {
  const CharacterPage({
    super.key,
    required this.characterName,
    required this.backgroundImageUrl,
  });

  final String characterName;
  final String backgroundImageUrl;

  static Widget of(BuildContext context, String tag) {
    return provideCharacterPageDependencies(
      context,
      character: tag,
      page: CharacterPage(
        characterName: tag,
        backgroundImageUrl: '',
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Screen.of(context).size == ScreenSize.small
        ? TagDetailPage(
            tagName: characterName,
            otherNamesBuilder: (context) =>
                switch (ref.watch(danbooruWikiProvider(characterName))) {
              WikiStateLoading _ => const SizedBox(height: 40, width: 40),
              WikiStateLoaded s => TagOtherNames(otherNames: s.wiki.otherNames),
              WikiStateError _ => const SizedBox.shrink(),
              WikiStateNotFound _ => const SizedBox.shrink(),
            },
            backgroundImageUrl: backgroundImageUrl,
          )
        : TagDetailPageDesktop(
            tagName: characterName,
            otherNamesBuilder: (context) =>
                switch (ref.watch(danbooruWikiProvider(characterName))) {
              WikiStateLoading _ => const SizedBox(height: 40, width: 40),
              WikiStateLoaded s => TagOtherNames(otherNames: s.wiki.otherNames),
              WikiStateError _ => const SizedBox.shrink(),
              WikiStateNotFound _ => const SizedBox.shrink(),
            },
          );
  }
}
