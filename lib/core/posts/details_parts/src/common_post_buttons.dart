// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import '../../../../foundation/animations/constants.dart';
import '../../../../foundation/clipboard.dart';
import '../../../../foundation/toast.dart';
import '../../../../foundation/url_launcher.dart';
import '../../../boorus/engine/engine.dart';
import '../../../configs/config/types.dart';
import '../../../images/providers.dart';
import '../../../premiums/providers.dart';
import '../../../settings/routes.dart';
import '../../../tags/show/routes.dart';
import '../../../widgets/adaptive_button_row.dart';
import '../../details_manager/routes.dart';
import '../../post/src/data/providers.dart';
import '../../post/src/routes/route_utils.dart';
import '../../post/src/types/post.dart';

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

    final commonButtons = [
      if (copy)
        if (config != null && configViewer != null)
          SimpleButtonData(
            icon: Icons.copy,
            title: 'Copy image',
            onPressed: () => copyImage(ref, post, config, configViewer),
          ),
      if (postLinkGenerator != null && config != null)
        if (!config.hasStrictSFW)
          SimpleButtonData(
            icon: Icons.open_in_browser,
            title: context.t.post.detail.view_in_browser,
            onPressed: () =>
                launchExternalUrlString(postLinkGenerator.getLink(post)),
          ),
      if (config != null)
        if (post.tags.isNotEmpty)
          SimpleButtonData(
            icon: Icons.label,
            title: 'View tags',
            onPressed: () => goToShowTaglistPage(
              ref,
              post,
              auth: config,
            ),
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

  Future<void> copyImage(
    WidgetRef ref,
    Post post,
    BooruConfigAuth config,
    BooruConfigViewer configViewer,
  ) async {
    void showError(String message) {
      showErrorToast(
        ref.context,
        message,
        duration: AppDurations.longToast,
      );
    }

    final bytes = await ref.read(
      defaultCachedImageFileProvider(
        defaultPostImageUrlBuilder(
          ref,
          config,
          configViewer,
        )(post),
      ).future,
    );

    if (bytes == null) {
      showError('Failed to get image bytes');
      return;
    }

    try {
      await AppClipboard.copyImageBytes(bytes);
      showToast(
        'Copied',
        position: ToastPosition.bottom,
        textPadding: const EdgeInsets.all(8),
        duration: AppDurations.shortToast,
      );
    } on Exception catch (e) {
      showError('Failed to copy image: $e');
      return;
    }
  }
}
