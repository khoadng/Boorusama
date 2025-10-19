// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_popover/flutter_popover.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../foundation/platform.dart';
import '../../../../posts/post/types.dart';
import '../../../../settings/routes.dart';
import '../../../../widgets/hover_aware_container.dart';
import '../../../lock/providers.dart';
import 'desktop_video_option_sheet.dart';
import 'mobile_video_option_sheet.dart';

class MoreOptionsControlButton extends StatelessWidget {
  const MoreOptionsControlButton({
    required this.speed,
    required this.onSpeedChanged,
    required this.post,
    required this.popoverController,
    super.key,
  });

  final double speed;
  final void Function(double speed) onSpeedChanged;
  final Post post;
  final PopoverController? popoverController;

  @override
  Widget build(BuildContext context) {
    return isDesktopPlatform() && popoverController != null
        ? DesktopVideoOptionButton(
            speed: speed,
            onSpeedChanged: onSpeedChanged,
            post: post,
            popoverController: popoverController!,
          )
        : MobileVideoOptionsButton(
            speed: speed,
            onSpeedChanged: onSpeedChanged,
            post: post,
          );
  }
}

class DesktopVideoOptionButton extends StatelessWidget {
  const DesktopVideoOptionButton({
    super.key,
    required this.speed,
    required this.onSpeedChanged,
    required this.post,
    required this.popoverController,
  });

  final double speed;
  final void Function(double speed) onSpeedChanged;
  final Post post;
  final PopoverController popoverController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Popover(
      controller: popoverController,
      triggerMode: PopoverTriggerMode.tap,
      preferredDirection: AxisDirection.up,
      constrainAxis: Axis.vertical,
      offset: const Offset(0, -16),
      consumeOutsideTap: true,
      overlayChildBuilder: (context) => LayoutBuilder(
        builder: (context, constraints) => VideoOptionContainer(
          backgroundColor: colorScheme.surfaceContainer.withValues(alpha: 0.95),
          constraints: BoxConstraints(
            maxWidth: min(constraints.maxWidth, 300),
          ),
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          child: Consumer(
            builder: (_, ref, _) {
              final screenLockNotifier = ref.watch(screenLockProvider.notifier);

              return DesktopVideoOptionSheet(
                speed: speed,
                onSpeedChanged: onSpeedChanged,
                onLock: () {
                  popoverController.hide();
                  screenLockNotifier.lock();
                },
                onOpenSettings: () {
                  popoverController.hide();
                  openImageViewerSettingsPage(ref);
                },
                post: post,
              );
            },
          ),
        ),
      ),
      child: ListenableBuilder(
        listenable: popoverController,
        builder: (context, child) {
          final isOpen = popoverController.isShowing;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isOpen ? colorScheme.surfaceContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 150),
              turns: isOpen ? 0.125 : 0,
              child: child,
            ),
          );
        },
        child: const Icon(
          Symbols.settings,
          fill: 1,
        ),
      ),
    );
  }
}

class MobileVideoOptionsButton extends ConsumerWidget {
  const MobileVideoOptionsButton({
    super.key,
    required this.speed,
    required this.onSpeedChanged,
    required this.post,
  });

  final double speed;
  final void Function(double speed) onSpeedChanged;
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenLockNotifier = ref.watch(screenLockProvider.notifier);

    return Tooltip(
      message: context.t.settings.settings,
      preferBelow: false,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => showModalBottomSheet(
            context: context,
            builder: (_) => VideoOptionContainer(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: MobileVideoOptionSheet(
                value: speed,
                onSpeedChanged: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => PlaybackSpeedActionSheet(
                      onChanged: onSpeedChanged,
                    ),
                  );
                },
                onOpenSettings: () {
                  Navigator.of(context).pop();
                  openImageViewerSettingsPage(ref);
                },
                onLock: () {
                  Navigator.of(context).pop();
                  screenLockNotifier.lock();
                },
                post: post,
              ),
            ),
          ),
          child: const HoverAwareContainer(
            child: Icon(
              Symbols.settings,
              fill: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class VideoOptionContainer extends StatelessWidget {
  const VideoOptionContainer({
    super.key,
    this.borderRadius,
    this.constraints,
    this.padding,
    this.backgroundColor,
    required this.child,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final BoxConstraints? constraints;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      constraints: constraints,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainer,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
