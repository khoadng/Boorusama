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
        otherNames: ref
            .watch(danbooruWikiProvider(characterName))
            .when(
              data: (wiki) => wiki == null
                  ? const SizedBox.shrink()
                  : TagOtherNames(otherNames: wiki.otherNames),
              loading: () => const TagOtherNames(otherNames: null),
              error: (_, _) => const SizedBox.shrink(),
            ),
      ),
    );
  }
}
