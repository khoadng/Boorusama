// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../animations/constants.dart';
import '../error_monitor.dart';
import '../info/device_info.dart';
import '../loggers.dart';
import '../picker.dart';

Future<void> failsafe({
  required Object error,
  required StackTrace stackTrace,
  required BootLogger logger,
}) async {
  final deviceInfo = await DeviceInfoService(
    plugin: DeviceInfoPlugin(),
  ).getDeviceInfo();
  final logs = logger.dump();

  runApp(
    ProviderScope(
      overrides: [
        deviceInfoProvider.overrideWithValue(deviceInfo),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: AppFailedToInitialize(
          error: error,
          stackTrace: stackTrace,
          logs: logs,
        ),
      ),
    ),
  );
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
                      Text(
                        'An error has occurred, please report this to the developer'
                            .hc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
  ) => pickDirectoryPathToastOnError(
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
