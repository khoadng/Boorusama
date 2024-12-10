// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

// Project imports:
import '../info/app_info.dart';
import 'platform.dart';

Future<void> initialize() async {
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow(
    const WindowOptions(
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
                    ],
                  ),
                ),
        ),
        body: child,
      ),
    );
  }
}

class MacosCaption extends StatefulWidget {
  const MacosCaption({
    super.key,
    this.backgroundColor,
    this.brightness,
  });

  final Color? backgroundColor;
  final Brightness? brightness;

  @override
  State<MacosCaption> createState() => _MacosCaptionState();
}

class _MacosCaptionState extends State<MacosCaption> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            (widget.brightness == Brightness.dark
                ? const Color(0xff1C1C1C)
                : Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(
            child: DragToMoveArea(
              child: SizedBox(
                height: double.infinity,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: widget.brightness == Brightness.light
                              ? Colors.black.withOpacity(0.8956)
                              : Colors.white,
                          fontSize: 14,
                        ),
                        child: Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }
}
