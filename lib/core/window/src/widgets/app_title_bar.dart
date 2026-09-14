// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../foundation/info/app_info.dart';
import '../../../../foundation/platform.dart';
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
    final platform = ref.watch(appPlatformProvider);
    final isDesktop = switch (platform) {
      AppPlatform.macos || AppPlatform.windows || AppPlatform.linux => true,
      AppPlatform.android ||
      AppPlatform.ios ||
      AppPlatform.web ||
      AppPlatform.unknown => false,
    };

    if (!isDesktop) return child;

    final colorScheme = Kurumi.themeOf(context).colorScheme;

    return KurumiDesktopWindowFrame(
      isMacOS: platform == AppPlatform.macos,
      backgroundColor: colorScheme.surface,
      brightness: colorScheme.brightness,
      logo: Image.asset(
        'assets/images/logo.png',
        width: 18,
        height: 18,
        isAntiAlias: true,
        filterQuality: FilterQuality.none,
      ),
      title: Text(
        appName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: const PinWindowButton(
        iconSize: 14,
      ),
      child: child,
    );
  }
}
