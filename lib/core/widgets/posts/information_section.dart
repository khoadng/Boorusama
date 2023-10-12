// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/time.dart';
import 'package:boorusama/widgets/widgets.dart';

class InformationSection extends ConsumerWidget {
  const InformationSection({
    super.key,
    this.padding,
    this.characterTags = const [],
    this.artistTags = const [],
    this.copyrightTags = const [],
    this.createdAt,
    this.source,
    this.onArtistTagTap,
    this.showSource = false,
  });

  final EdgeInsetsGeometry? padding;
  final bool showSource;
  final List<String> characterTags;
  final List<String> artistTags;
  final List<String> copyrightTags;
  final DateTime? createdAt;
  final PostSource? source;

  final void Function(BuildContext context, String artist)? onArtistTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  characterTags.isEmpty
                      ? 'Original'
                      : generateCharacterOnlyReadableName(characterTags)
                          .replaceUnderscoreWithSpace()
                          .titleCase,
                  overflow: TextOverflow.fade,
                  style: context.textTheme.titleLarge,
                  maxLines: 1,
                  softWrap: false,
                ),
                const SizedBox(height: 5),
                Text(
                  copyrightTags.isEmpty
                      ? 'Original'
                      : generateCopyrightOnlyReadableName(copyrightTags)
                          .replaceUnderscoreWithSpace()
                          .titleCase,
                  overflow: TextOverflow.fade,
                  style: context.textTheme.bodyMedium,
                  maxLines: 1,
                  softWrap: false,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    if (artistTags.isNotEmpty)
                      Flexible(
                        child: CompactChip(
                          textColor: Colors.white,
                          label: artistTags.first.replaceUnderscoreWithSpace(),
                          onTap: () =>
                              onArtistTagTap?.call(context, artistTags.first),
                          backgroundColor: ref.getTagColor(
                            context,
                            TagCategory.artist.name,
                            themeMode: ThemeMode.light,
                          ),
                        ),
                      ),
                    if (artistTags.isNotEmpty) const SizedBox(width: 5),
                    if (createdAt != null)
                      Text(
                        createdAt!
                            .fuzzify(locale: Localizations.localeOf(context)),
                        style: context.textTheme.bodySmall,
                      ),
                  ],
                )
              ],
            ),
          ),
          if (source != null && showSource)
            source!.whenWeb(
              (source) => GestureDetector(
                onTap: () => launchExternalUrl(source.uri),
                child: WebsiteLogo(
                  url: source.faviconUrl,
                ),
              ),
              () => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

class SimpleInformationSection extends ConsumerWidget {
  const SimpleInformationSection({
    super.key,
    required this.post,
    this.padding,
    this.showSource = false,
  });

  final EdgeInsetsGeometry? padding;
  final bool showSource;
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(booruBuilderProvider);
    final supportArtist = booruBuilder?.isArtistSupported ?? false;

    return InformationSection(
      characterTags: post.characterTags ?? [],
      artistTags: post.artistTags ?? [],
      copyrightTags: post.copyrightTags ?? [],
      createdAt: post.createdAt,
      source: post.source,
      showSource: showSource,
      onArtistTagTap: supportArtist
          ? (context, artist) => goToArtistPage(context, artist)
          : null,
    );
  }
}
