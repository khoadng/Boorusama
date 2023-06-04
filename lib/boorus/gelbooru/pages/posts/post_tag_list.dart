// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart' hide TagsState;
import 'package:intl/intl.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/tag_colors.dart';
import 'package:boorusama/foundation/platform.dart';

class PostTagList extends ConsumerWidget {
  const PostTagList({
    super.key,
    this.maxTagWidth,
    this.onTap,
  });

  final double? maxTagWidth;
  final void Function(Tag tag)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);

    if (tags == null) {
      return SpinKitPulse(
        size: 42,
        color: Theme.of(context).colorScheme.onBackground,
      );
    }

    final widgets = <Widget>[];
    for (final g in tags) {
      widgets
        ..add(_TagBlockTitle(
          title: g.groupName,
          isFirstBlock: g.groupName == tags.first.groupName,
        ))
        ..add(_buildTags(
          context,
          g.tags,
          onTap,
        ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widgets,
      ],
    );
  }

  Widget _buildTags(
    BuildContext context,
    List<Tag> tags,
    void Function(Tag tag)? onTap,
  ) {
    return Tags(
      alignment: WrapAlignment.start,
      runSpacing: isMobilePlatform() ? 0 : 4,
      itemCount: tags.length,
      itemBuilder: (index) {
        final tag = tags[index];

        return GestureDetector(
          onTap: () => onTap?.call(tag),
          child: _Chip(tag: tag, maxTagWidth: maxTagWidth),
        );
      },
    );
  }
}

class _Chip extends ConsumerWidget {
  const _Chip({
    required this.tag,
    required this.maxTagWidth,
  });

  final Tag tag;
  final double? maxTagWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: getTagColor(tag.category, theme),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          label: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxTagWidth ?? MediaQuery.of(context).size.width * 0.7,
            ),
            child: Text(
              _getTagStringDisplayName(tag),
              overflow: TextOverflow.fade,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Chip(
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          backgroundColor: Colors.grey[800],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          label: Text(
            NumberFormat.compact().format(tag.postCount),
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

String _getTagStringDisplayName(Tag tag) => tag.displayName.length > 30
    ? '${tag.displayName.substring(0, 30)}...'
    : tag.displayName;

class _TagBlockTitle extends StatelessWidget {
  const _TagBlockTitle({
    required this.title,
    this.isFirstBlock = false,
  });

  final bool isFirstBlock;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(
        height: 5,
      ),
      _TagHeader(
        title: title,
      ),
    ]);
  }
}

class _TagHeader extends StatelessWidget {
  const _TagHeader({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}
