// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/pages/boorus/website_logo.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/utils/time_utils.dart';

class InformationSection extends StatelessWidget {
  const InformationSection({
    super.key,
    required this.post,
    this.padding,
    this.showSource = false,
  });

  final DanbooruPost post;
  final EdgeInsetsGeometry? padding;
  final bool showSource;

  @override
  Widget build(BuildContext context) {
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
                  post.characterTags.isEmpty
                      ? 'Original'
                      : generateCharacterOnlyReadableName(post)
                          .removeUnderscoreWithSpace()
                          .titleCase,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  softWrap: false,
                ),
                const SizedBox(height: 5),
                Text(
                  post.copyrightTags.isEmpty
                      ? 'Original'
                      : generateCopyrightOnlyReadableName(post)
                          .removeUnderscoreWithSpace()
                          .titleCase,
                  overflow: TextOverflow.fade,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  softWrap: false,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Flexible(
                      child: post.artistTags.firstOrNull.toOption().fold(
                            () => const SizedBox.shrink(),
                            (artist) => Material(
                              borderRadius: BorderRadius.circular(6),
                              color: getTagColor(
                                TagCategory.artist,
                                ThemeMode.amoledDark,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: () => goToArtistPage(context, artist),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 4,
                                  ),
                                  child: Text(
                                    artist.removeUnderscoreWithSpace(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                    post.artistTags.firstOrNull.toOption().fold(
                          () => const SizedBox.shrink(),
                          (_) => const SizedBox(width: 5),
                        ),
                    Text(
                      post.createdAt
                          .fuzzify(locale: Localizations.localeOf(context)),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                )
              ],
            ),
          ),
          if (showSource)
            post.source.whenWeb(
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
