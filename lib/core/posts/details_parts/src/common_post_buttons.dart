// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/url_launcher.dart';
import '../../../configs/config/types.dart';
import '../../../images/copy.dart';
import '../../../settings/routes.dart';
import '../../../tags/tag/routes.dart';
import '../../../widgets/adaptive_button_row.dart';
import '../../post/src/data/providers.dart';
import '../../post/src/routes/route_utils.dart';
import '../../post/src/types/post.dart';

class CommonPostButtonsBuilder extends ConsumerWidget with CopyImageMixin {
  const CommonPostButtonsBuilder({
    required this.builder,
    required this.post,
    required this.config,
    required this.configViewer,
    required this.onStartSlideshow,
    super.key,
  });

  final Widget Function(BuildContext context, List<ButtonData> commonButtons)
  builder;
  final Post post;
  @override
  final BooruConfigAuth config;
  @override
  final BooruConfigViewer configViewer;
  final VoidCallback onStartSlideshow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postLinkGenerator = ref.watch(postLinkGeneratorProvider(config));

    final commonButtons = [
      SimpleButtonData(
        icon: Icons.copy,
        title: 'Copy image',
        onPressed: () => copyImage(ref, post),
      ),
      if (!config.hasStrictSFW)
        SimpleButtonData(
          icon: Icons.open_in_browser,
          title: context.t.post.detail.view_in_browser,
          onPressed: () =>
              launchExternalUrlString(postLinkGenerator.getLink(post)),
        ),
      if (post.tags.isNotEmpty)
        SimpleButtonData(
          icon: Icons.label,
          title: 'View tags',
          onPressed: () => goToShowTaglistPage(ref, post),
        ),
      if (post.hasFullView)
        SimpleButtonData(
          icon: Icons.fullscreen,
          title: context.t.post.image_fullview.view_original,
          onPressed: () => goToOriginalImagePage(ref, post),
        ),
      SimpleButtonData(
        icon: Icons.slideshow,
        title: 'Slideshow',
        onPressed: onStartSlideshow,
      ),
      SimpleButtonData(
        icon: Icons.settings,
        title: context.t.settings.settings,
        onPressed: () => openImageViewerSettingsPage(ref),
      ),
    ];

    return builder(context, commonButtons);
  }
}
