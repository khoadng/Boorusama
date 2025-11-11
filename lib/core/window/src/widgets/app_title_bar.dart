// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

// Project imports:
import '../../../../foundation/info/app_info.dart';
import '../../../../foundation/platform.dart';
import 'macos_caption.dart';
import 'pin_window_button.dart';

class AppTitleBar extends ConsumerWidget {
  const AppTitleBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);
    final appName = appInfo.appName;

    return isDesktopPlatform() ? _buildTitleBar(appName, context) : child;
  }

  Widget _buildTitleBar(String appName, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return VirtualWindowFrame(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kWindowCaptionHeight),
          child: isMacOS()
              ? MacosCaption(
                  backgroundColor: colorScheme.surface,
                  brightness: colorScheme.brightness,
                )
              : WindowCaption(
                  backgroundColor: colorScheme.surface,
                  brightness: colorScheme.brightness,
                  title: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 18,
                          height: 18,
                          isAntiAlias: true,
                          filterQuality: FilterQuality.none,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: Text(
                          appName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: PinWindowButton(
                          iconSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        body: child,
      ),
    );
  }
}
