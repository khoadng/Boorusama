// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../../premiums/providers.dart';
import '../../../../theme.dart';
import '../../../details_manager/types.dart';
import '../../../details_parts/types.dart';
import '../../../details_parts/widgets.dart';
import '../../../post/post.dart';
import '../../details.dart';
import 'post_details_controller.dart';

List<Widget> defaultActions({
  required Widget? note,
  required Widget? fallbackMoreButton,
}) {
  return [
    ?note,
    ?fallbackMoreButton,
  ];
}

class DefaultFallbackBackupMoreButton<T extends Post> extends ConsumerWidget {
  const DefaultFallbackBackupMoreButton({
    required this.controller,
    this.layoutConfig,
    this.authConfig,
    this.viewerConfig,
    super.key,
  });

  final LayoutConfigs? layoutConfig;
  final PostDetailsController<T> controller;
  final BooruConfigAuth? authConfig;
  final BooruConfigViewer? viewerConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageViewController = PostDetailsPageViewScope.of(context);
    final layoutPreviewDetails = layoutConfig?.previewDetails;

    final hasToolbar =
        layoutPreviewDetails?.any(
          (part) => part == convertDetailsPart(DetailsPart.toolbar),
        ) ??
        true;

    if (ref.watch(hasPremiumLayoutProvider) && !hasToolbar) {
      return ValueListenableBuilder(
        valueListenable: controller.currentPost,
        builder: (context, post, _) => SizedBox(
          width: 40,
          child: Material(
            color: context.extendedColorScheme.surfaceContainerOverlay,
            shape: const CircleBorder(),
            child: CommonPostPopupMenu(
              post: post,
              onStartSlideshow: () => pageViewController.startSlideshow(),
              config: authConfig,
              configViewer: viewerConfig,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
