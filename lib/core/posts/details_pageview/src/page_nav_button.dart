// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../theme.dart';
import 'post_details_page_view_controller.dart';

class PageNavButton extends StatelessWidget {
  const PageNavButton({
    required this.controller,
    required this.visibleWhen,
    required this.icon,
    required this.onPressed,
    required this.alignment,
    super.key,
  });

  final PostDetailsPageViewController controller;
  final bool Function(int page) visibleWhen;
  final Widget icon;
  final void Function()? onPressed;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: controller.overlay,
      builder: (_, overlay, child) =>
          overlay ? child! : const SizedBox.shrink(),
      child: ValueListenableBuilder(
        valueListenable: controller.zoom,
        builder: (_, zoom, child) => !zoom ? child! : const SizedBox.shrink(),
        child: ValueListenableBuilder(
          valueListenable: controller.currentPage,
          builder: (context, page, _) => visibleWhen(page)
              ? Align(
                  alignment: alignment,
                  child: MaterialButton(
                    color: context.extendedColorScheme.surfaceContainerOverlay,
                    shape: const CircleBorder(),
                    padding: context.isLargeScreen
                        ? const EdgeInsets.all(8)
                        : null,
                    onPressed: onPressed,
                    child: Theme(
                      data: theme.copyWith(
                        iconTheme: theme.iconTheme.copyWith(
                          color: context
                              .extendedColorScheme
                              .onSurfaceContainerOverlay,
                        ),
                      ),
                      child: icon,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
