// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:readmore/readmore.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/animations.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/loggers/app_logger.dart';
import 'package:boorusama/foundation/loggers/logger.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/scrolling.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:boorusama/widgets/widgets.dart';

class DebugLogsPage extends ConsumerStatefulWidget {
  const DebugLogsPage({
    super.key,
    this.hasAppBar = true,
  });

  final bool hasAppBar;

  @override
  ConsumerState<DebugLogsPage> createState() => _DebugLogsPageState();
}

class _DebugLogsPageState extends ConsumerState<DebugLogsPage> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(debugLogsProvider);

    // Function to copy logs to clipboard
    void copyLogsToClipboard() {
      final data = ref.read(appLoggerProvider).dump();
      Clipboard.setData(ClipboardData(text: data));

      showSimpleSnackBar(
        context: context,
        content: const Text('settings.debug_logs.logs_copied').tr(),
      );
    }

    return ConditionalParentWidget(
      condition: widget.hasAppBar,
      conditionalBuilder: (child) => Scaffold(
        appBar: AppBar(
          title: const Text('settings.debug_logs.debug_logs').tr(),
          actions: [
            IconButton(
              icon: const Icon(Symbols.content_copy),
              onPressed: copyLogsToClipboard,
            ),
            IconButton(
              icon: const Icon(Symbols.download),
              onPressed: () async {
                await writeLogsToFile(logs);
              },
            ),
          ],
        ),
        floatingActionButton: ScrollToBottom(
          scrollController: scrollController,
          child: BooruScrollToBottomButton(
            onPressed: () {
              scrollController.animateToWithAccessibility(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                reduceAnimations: ref.read(settingsProvider).reduceAnimations,
              );
            },
          ),
        ),
        body: child,
      ),
      child: _buildBody(logs),
    );
  }

  Future<void> writeLogsToFile(List<LogData> logs) async =>
      tryGetDownloadDirectory().run().then((value) => value.fold(
            (error) => showErrorToast(error.name),
            (directory) async {
              final file = File('${directory.path}/boorusama_logs.txt');
              final buffer = StringBuffer();
              for (final log in logs) {
                buffer.write(
                    '[${log.dateTime}][${log.serviceName}]: ${log.message}\n');
              }
              await file.writeAsString(buffer.toString());
              showSuccessToast(
                'Logs written to ${file.path}',
                duration: AppDurations.longToast,
              );
            },
          ));

  Widget _buildBody(List<LogData> logs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      controller: scrollController,
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                log.dateTime.toString(),
                style: TextStyle(
                  color: context.theme.hintColor,
                ),
              ),
              Wrap(
                spacing: 0,
                children: [
                  Text(
                    '[${log.serviceName}]: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: context.colorScheme.primary,
                    ),
                  ),
                  ReadMoreText(
                    log.message,
                    trimExpandedText: ' less',
                    trimCollapsedText: ' more',
                    trimMode: TrimMode.Line,
                    trimLines: 3,
                    style: TextStyle(
                      fontSize: 13,
                      color: switch (log.level) {
                        LogLevel.info =>
                          context.colorScheme.onSurface.withAlpha(222),
                        LogLevel.warning => Colors.yellow.withAlpha(222),
                        LogLevel.error => context.colorScheme.error,
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
