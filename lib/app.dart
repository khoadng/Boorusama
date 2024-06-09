// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/analytics.dart';
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/picker.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/scrolling.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/platforms/platforms.dart';

const kMinSideBarWidth = 62.0;

class App extends StatelessWidget {
  const App({
    super.key,
    required this.appName,
    required this.initialSettings,
  });

  final String appName;
  final Settings initialSettings;

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: OKToast(
        child: AnalyticsScope(
          builder: (analyticsEnabled) => ThemeBuilder(
            builder: (theme, themeMode) => RouterBuilder(
              builder: (context, router) => ScrollBehaviorBuilder(
                builder: (context, behavior) => _buildApp(
                  theme,
                  themeMode,
                  context,
                  router,
                  behavior,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApp(
    ThemeData theme,
    ThemeMode themeMode,
    BuildContext context,
    GoRouter router,
    ScrollBehavior? scrollBehavior,
  ) {
    return MaterialApp.router(
      builder: (context, child) => ConditionalParentWidget(
        condition: isDesktopPlatform(),
        conditionalBuilder: (child) => WindowTitleBar(
          appName: appName,
          child: child,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: Theme.of(context).iconTheme.copyWith(
                  weight: isWindows() ? 200 : 400,
                ),
          ),
          child: child!,
        ),
      ),
      scrollBehavior: scrollBehavior,
      theme: theme,
      themeMode: themeMode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: appName,
      routerConfig: router,
    );
  }
}

class AppFailedToInitialize extends ConsumerWidget {
  const AppFailedToInitialize({
    super.key,
    required this.error,
    required this.stackTrace,
    required this.logs,
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
                        shrinkWrap: true,
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
                                deviceInfo.iosDeviceInfo!.data[key].toString()),
                          )
                      ]
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
        onPick: (path) async {
          final file = File('$path/boorusama_crash.txt');
          await file.writeAsString(data);
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Copied'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      );
}
