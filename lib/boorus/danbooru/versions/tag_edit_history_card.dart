// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/users/creator/creator.dart';
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/time.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'danbooru_post_version.dart';

class TagEditHistoryCard extends StatelessWidget {
  const TagEditHistoryCard({
    super.key,
    required this.version,
    required this.onUserTap,
  });

  final DanbooruPostVersion version;
  final void Function() onUserTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
        color: context.colorScheme.surfaceContainer,
      ),
      child: Row(
        children: [
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
                            locale: context.locale,
                          ),
                          style: TextStyle(
                            color: context.colorScheme.hintColor,
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
              onTap: () => goToSearchPage(context, tag: e),
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
              onTap: () => goToSearchPage(context, tag: e),
            ),
          ),
        ],
      ),
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
            color: version.updater.getColor(context),
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
        color: context.colorScheme.surface,
      ),
      child: Text(
        '${version.version}',
      ),
    );
  }
}

class PostVersionTagText extends StatelessWidget {
  const PostVersionTagText({
    super.key,
    required this.tag,
    required this.style,
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
