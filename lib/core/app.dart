// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'analytics.dart';
import 'foundation/animations.dart';
import 'foundation/error.dart';
import 'foundation/networking.dart';
import 'foundation/picker.dart';
import 'foundation/platform.dart';
import 'foundation/scrolling.dart';
import 'foundation/windows.dart';
import 'info/app_info.dart';
import 'info/device_info.dart';
import 'router.dart';
import 'settings/providers.dart';
import 'theme/theme.dart';

const kMinSideBarWidth = 62.0;
const kMaxSideBarWidth = 250.0;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const Portal(
      child: OKToast(
        child: AnalyticsScope(
          child: NetworkListener(
            child: _App(),
          ),
        ),
      ),
    );
  }
}

class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appInfo = ref.watch(appInfoProvider);
    final reduceAnimations =
        ref.watch(settingsProvider.select((value) => value.reduceAnimations));

    return ThemeBuilder(
      builder: (theme, themeMode) => MaterialApp.router(
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            iconTheme: Theme.of(context).iconTheme.copyWith(
                  weight: isWindows() ? 200 : 400,
                ),
          ),
          child: AnnotatedRegion(
            // Needed to make the bottom navigation bar transparent
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              statusBarBrightness: theme.brightness,
              statusBarIconBrightness: context.onBrightness,
            ),
            child: AppTitleBar(child: child!),
          ),
        ),
        scrollBehavior: reduceAnimations ? const NoOverscrollBehavior() : null,
        theme: theme,
        themeMode: themeMode,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        title: appInfo.appName,
        routerConfig: router,
      ),
    );
  }
}

class AppFailedToInitialize extends ConsumerWidget {
  const AppFailedToInitialize({
    required this.error,
    required this.stackTrace,
    required this.logs,
    super.key,
  });

  final Object error;
  final StackTrace? stackTrace;
  final String logs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceInfo = ref.watch(deviceInfoProvider);
    final stackString = stackTrace?.prettyPrinted(maxFrames: 10);
    final errorString = '$error\n\n$stackString';
    final data = wrapIntoCodeBlock(errorString);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'An error has occurred, please report this to the developer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MarkdownBody(
                        data: data,
                      ),
                      const SizedBox(height: 16),
                      if (deviceInfo.androidDeviceInfo != null) ...[
                        for (final key
                            in deviceInfo.androidDeviceInfo!.data.keys)
                          ListTile(
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            horizontalTitleGap: 0,
                            minVerticalPadding: 0,
                            minLeadingWidth: 0,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(key.sentenceCase),
                            subtitle: Text(
                              deviceInfo.androidDeviceInfo!.data[key]
                                  .toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ] else if (deviceInfo.iosDeviceInfo != null) ...[
                        for (final key in deviceInfo.iosDeviceInfo!.data.keys)
                          ListTile(
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ),
                            horizontalTitleGap: 0,
                            minVerticalPadding: 0,
                            minLeadingWidth: 0,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              key.sentenceCase,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              deviceInfo.iosDeviceInfo!.data[key].toString(),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            OverflowBar(
              children: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    final data = composeError(errorString, deviceInfo);
                    _saveTo(context, data);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String composeError(String errorString, DeviceInfo deviceInfo) {
    final data = deviceInfo.dump();

    return '$errorString\n\n$logs\n\n$data';
  }

  Future<void> _saveTo(
    BuildContext context,
    String data,
  ) =>
      pickDirectoryPathToastOnError(
        context: context,
        onPick: (path) async {
          final file = File('$path/boorusama_crash.txt');
          await file.writeAsString(data);
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Copied'),
              duration: AppDurations.shortToast,
            ),
          );
        },
      );
}
