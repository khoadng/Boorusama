// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/images/booru_image.dart';
import '../../../../../core/posts/details/routes.dart';
import '../../../../../core/posts/post/types.dart';
import '../../../../../core/search/search/routes.dart';
import '../../../../../core/themes/theme/types.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../users/user/providers.dart';
import '../types/danbooru_post_version.dart';
import '../types/utils.dart';
import 'tag_changed_text.dart';

class TagEditHistoryCard extends StatelessWidget {
  const TagEditHistoryCard({
    required this.version,
    this.onUserTap,
    this.configSearch,
    super.key,
  });

  final DanbooruPostVersion version;
  final void Function()? onUserTap;
  final BooruConfigSearch? configSearch;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final thumbnail = resolveThumbnailWithRatingFilter(
      version: version,
      configSearch: configSearch,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 0.2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceContainerLow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thumbnail case final thumb?)
            if (configSearch case final config?)
              Consumer(
                builder: (context, ref, _) => SizedBox(
                  width: 100,
                  child: Material(
                    child: InkWell(
                      onTap: () {
                        goToSinglePostDetailsPage(
                          ref: ref,
                          postId: NumericPostId(version.postId),
                          configSearch: config,
                        );
                      },
                      child: BooruImage(
                        config: config.auth,
                        imageUrl: thumb,
                      ),
                    ),
                  ),
                ),
              ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(context),
                _buildTags(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndex(context),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(child: _buildUsername(context)),
                      const Text(
                        ' • ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      DateTooltip(
                        date: version.updatedAt,
                        child: Text(
                          version.updatedAt.fuzzify(
                            locale: Localizations.localeOf(context),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TagChangedText(
                  title: '',
                  added: version.addedTags.toSet(),
                  removed: version.removedTags.toSet(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Wrap(
            children: [
              ...version.addedTags.map(
                (e) => PostVersionTagText(
                  tag: e,
                  style: const TextStyle(
                    color: Colors.green,
                  ),
                  onTap: () => goToSearchPage(ref, tag: e),
                ),
              ),
              ...version.removedTags.map(
                (e) => PostVersionTagText(
                  tag: e,
                  style: const TextStyle(
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.red,
                  ),
                  onTap: () => goToSearchPage(ref, tag: e),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsername(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onUserTap,
        child: Text(
          version.updater.name.replaceAll('_', ' '),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: DanbooruUserColor.of(
              context,
            ).fromLevel(version.updater.level),
          ),
        ),
      ),
    );
  }

  Widget _buildIndex(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Text(
        '${version.version}',
      ),
    );
  }
}

class PostVersionTagText extends StatelessWidget {
  const PostVersionTagText({
    required this.tag,
    required this.style,
    super.key,
    this.onTap,
  });

  final String tag;
  final TextStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 1,
          ),
          child: Text(
            tag,
            style: style,
          ),
        ),
      ),
    );
  }
}
