import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/providers.dart';
import '../../../../configs/listing/providers.dart';
import '../../../../configs/listing/types.dart';
import '../../../../downloads/downloader/providers.dart';
import '../../../../routers/routers.dart';
import '../../../details_parts/widgets.dart';
import '../../../post/types.dart';

class DefaultImagePreviewQuickActions extends ConsumerWidget {
  const DefaultImagePreviewQuickActions({required this.post, super.key});
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final builder = ref.watch(booruBuilderProvider(config));
    final actions = ref.watch(thumbnailActionsProvider);
    final artist = (post.artistTags?.isNotEmpty ?? false)
        ? chooseArtistTag(post.artistTags!)
        : null;
    final buttons = <Widget>[];
    for (final action in actions.actions) {
      final button = switch (action) {
        ThumbnailAction.defaultAction =>
          builder?.quickFavoriteButtonBuilder?.call(context, ref, post),
        ThumbnailAction.bookmark => _CompactActionBackground(
          diameter: 33,
          child: KurumiTooltip(
            message: context.t.post.action.bookmark,
            child: BookmarkPostLikeButtonButton(post: post),
          ),
        ),
        ThumbnailAction.download => _CompactActionBackground(
          diameter: 32,
          child: _ThumbnailDownloadButton(post: post),
        ),
        ThumbnailAction.artist =>
          artist == null
              ? null
              : _CompactActionBackground(
                  diameter: 32,
                  child: IconButton(
                    padding: const EdgeInsets.all(4),
                    tooltip: '${context.t.post.action.view_artist}: $artist',
                    onPressed: () => goToArtistPage(ref, artist),
                    icon: const Icon(Symbols.person),
                  ),
                ),
      };
      if (button != null) {
        buttons.add(KeyedSubtree(key: ValueKey(action), child: button));
      }
    }
    return ThumbnailActionGroup(children: buttons);
  }
}

class _ThumbnailDownloadButton extends ConsumerWidget {
  const _ThumbnailDownloadButton({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(
      downloadNotifierProvider(
        ref.watch(
          downloadNotifierParamsProvider((
            ref.watchConfigAuth,
            ref.watchConfigDownload,
          )),
        ),
      ).notifier,
    );

    return IconButton(
      padding: const EdgeInsets.all(4),
      tooltip: context.t.download.download,
      onPressed: () => notifier.download(post),
      icon: const Icon(Symbols.download),
    );
  }
}

class _CompactActionBackground extends StatelessWidget {
  const _CompactActionBackground({required this.diameter, required this.child});

  final double diameter;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.extendedColorScheme.surfaceContainerOverlay,
        ),
      ),
      child,
    ],
  );
}

/// The parent supplies the space left after reserving grid overlays.
class ThumbnailActionGroup extends StatelessWidget {
  const ThumbnailActionGroup({required this.children, super.key});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const extent = 33.0;
      const gap = 4.0;
      if (constraints.maxWidth < extent ||
          constraints.maxHeight < extent ||
          children.isEmpty) {
        return const SizedBox.shrink();
      }
      final fitsVertically = constraints.maxHeight >= extent * 2 + gap;
      final fitsHorizontally = constraints.maxWidth >= extent * 2 + gap;
      final horizontal =
          fitsHorizontally &&
          (!fitsVertically ||
              constraints.maxWidth >= constraints.maxHeight * 1.5);
      final count = fitsVertically || fitsHorizontally
          ? children.length.clamp(0, 2)
          : 1;
      return Flex(
        direction: horizontal ? Axis.horizontal : Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        spacing: gap,
        children: [
          for (final child in children.take(count).toList().reversed)
            SizedBox.square(dimension: extent, child: child),
        ],
      );
    },
  );
}
