// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/url_launcher.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/config/types.dart';
import '../../../premiums/providers.dart';
import '../../../settings/routes.dart';
import '../../../tags/show/routes.dart';
import '../../../widgets/adaptive_button_row.dart';
import '../../details_manager/routes.dart';
import '../../post/providers.dart';
import '../../post/routes.dart';
import '../../post/types.dart';
import 'toolbars/copy_post_button.dart';

class CommonPostButtonsBuilder extends ConsumerWidget {
  const CommonPostButtonsBuilder({
    required this.builder,
    required this.post,
    required this.onStartSlideshow,
    required this.config,
    required this.configViewer,
    super.key,
    this.copy = true,
  });

  final BooruConfigAuth? config;
  final BooruConfigViewer? configViewer;
  final Widget Function(BuildContext context, List<ButtonData> commonButtons)
  builder;
  final Post post;
  final VoidCallback onStartSlideshow;
  final bool copy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = this.config;
    final configViewer = this.configViewer;

    final postLinkGenerator = config != null
        ? ref.watch(postLinkGeneratorProvider(config))
        : null;

    final loginDetails = config != null
        ? ref.watch(booruLoginDetailsProvider(config))
        : null;
    final hasStrictSFW = loginDetails?.hasStrictSFW ?? true;

    final commonButtons = [
      if (copy)
        if (config != null && configViewer != null)
          ButtonData(
            widget: CopyPostButton(
              post: post,
              config: config,
              configViewer: configViewer,
            ),
            title: 'Copy'.hc,
            onTap: () => showPostCopySheet(
              context,
              post: post,
              config: config,
              configViewer: configViewer,
            ),
          ),
      if (postLinkGenerator != null && config != null)
        if (!hasStrictSFW)
          SimpleButtonData(
            icon: Icons.open_in_browser,
            title: context.t.post.action.view_in_browser,
            onPressed: () =>
                launchExternalUrlString(postLinkGenerator.getLink(post)),
          ),
      if (config != null)
        if (post.tags.isNotEmpty)
          SimpleButtonData(
            icon: Icons.label,
            title: context.t.post.action.view_tags,
            onPressed: () => goToShowTaglistPage(
              ref,
              post,
              auth: config,
            ),
          ),
      if (post.hasFullView)
        SimpleButtonData(
          icon: Icons.fullscreen,
          title: context.t.post.action.view_original,
          onPressed: () => goToOriginalImagePage(ref, post),
        ),
      SimpleButtonData(
        icon: Icons.slideshow,
        title: context.t.post.action.slideshow,
        onPressed: onStartSlideshow,
      ),
      if (ref.watch(showPremiumFeatsProvider))
        SimpleButtonData(
          icon: Icons.brush,
          title: context.t.settings.appearance.customize,
          placement: ButtonPlacement.menuOnly,
          onPressed: () {
            goToDetailsLayoutManagerForPreviewWidgets(ref);
          },
        ),
      SimpleButtonData(
        icon: Icons.settings,
        title: context.t.settings.settings,
        placement: ButtonPlacement.menuOnly,
        onPressed: () => openImageViewerSettingsPage(ref),
      ),
    ];

    return builder(context, commonButtons);
  }
}
