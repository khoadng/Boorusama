// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/theme.dart';
import 'platform.dart';

Future<void> initialize() async {
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow(
    WindowOptions(
      size: Size(1000, 700),
      minimumSize: Size(350, 350),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );
}

class AppTitleBar extends ConsumerWidget {
  const AppTitleBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);
    final appName = appInfo.appName;

    return isDesktopPlatform() ? _buildTitleBar(appName, context) : child;
  }

  Widget _buildTitleBar(String appName, BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.surface,
      child: Stack(
        children: [
          DoubleTapToMaxOrRestore(
            child: Row(
              children: [
                if (!isMacOS()) ...[
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
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 26),
            child: child,
          ),
        ],
      ),
    );
  }
}

class DoubleTapToMaxOrRestore extends StatelessWidget {
  const DoubleTapToMaxOrRestore({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        windowManager.startDragging();
      },
      onDoubleTap: () async {
        final isMaximized = await windowManager.isMaximized();
        if (!isMaximized) {
          windowManager.maximize();
        } else {
          windowManager.unmaximize();
        }
      },
      child: child,
    );
  }
}
