// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../error_monitor.dart';
import '../info/device_info.dart';
import 'crash_report_writer.dart';
import 'file_system_crash_report_writer.dart';
import 'runtime_error_widget.dart';

Future<void> failsafe({
  required Object error,
  required StackTrace stackTrace,
  required String logs,
}) async {
  initializeRuntimeErrorWidget();
  final deviceInfo = await DeviceInfoService(
    plugin: DeviceInfoPlugin(),
  ).getDeviceInfo();

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
          crashReportWriter: const FileSystemCrashReportWriter(),
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
    required this.crashReportWriter,
    super.key,
  });

  final Object error;
  final StackTrace? stackTrace;
  final String logs;
  final CrashReportWriter crashReportWriter;

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
                    crashReportWriter.save(context, data);
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
}
