// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:readmore/readmore.dart';

// Project imports:
import '../../../../foundation/animations/constants.dart';
import '../../../../foundation/clipboard.dart';
import '../../../../foundation/loggers.dart';
import '../../../../foundation/scrolling.dart';
import '../../../../foundation/toast.dart';
import '../../../downloads/path/directory.dart';
import '../../../themes/theme/types.dart';
import '../../../widgets/widgets.dart';
import '../providers/settings_provider.dart';

final debugLogsProvider = Provider<List<LogData>>((ref) {
  return ref.watch(appLoggerProvider).logs;
});

class DebugLogsPage extends ConsumerStatefulWidget {
  const DebugLogsPage({
    super.key,
  });

  @override
  ConsumerState<DebugLogsPage> createState() => _DebugLogsPageState();
}

class _DebugLogsPageState extends ConsumerState<DebugLogsPage> {
  final scrollController = ScrollController();
  String? selectedOption;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(debugLogsProvider);
    final services = logs.map((e) => e.serviceName).toSet();

    // Function to copy logs to clipboard
    void copyLogsToClipboard() {
      final data = ref.read(appLoggerProvider).dump();
      AppClipboard.copyAndToast(
        context,
        data,
        message: context.t.settings.debug_logs.logs_copied,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.settings.debug_logs.debug_logs),
        actions: [
          IconButton(
            icon: const Icon(Symbols.content_copy),
            onPressed: copyLogsToClipboard,
          ),
          IconButton(
            icon: const Icon(Symbols.download),
            onPressed: () async {
              await writeLogsToFile(context, logs);
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
      body: Column(
        children: [
          ChoiceOptionSelectorList(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            options: services.toList(),
            selectedOption: selectedOption,
            searchable: false,
            optionLabelBuilder: (option) => option ?? 'All',
            onSelected: (value) {
              setState(() {
                selectedOption = value;
              });
            },
          ),
          Expanded(
            child: _buildBody(logs),
          ),
        ],
      ),
    );
  }

  Future<void> writeLogsToFile(
    BuildContext context,
    List<LogData> logs,
  ) async {
    final result = await tryGetDownloadDirectory();

    switch (result) {
      case DownloadDirectoryFailure(:final message):
        if (context.mounted) {
          showErrorToast(
            context,
            message ?? 'Failed to get download directory',
          );
        }
      case DownloadDirectorySuccess(:final directory):
        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final file = File('${directory.path}/boorusama_logs_$timestamp.txt');
        final buffer = StringBuffer();
        for (final log in logs) {
          buffer.write(
            '[${log.dateTime}][${log.serviceName}]: ${log.message}\n',
          );
        }
        await file.writeAsString(buffer.toString());

        if (context.mounted) {
          showSuccessToast(
            context,
            'Logs written to ${file.path}',
            duration: AppDurations.longToast,
          );
        }
    }
  }

  Widget _buildBody(List<LogData> logs) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      controller: scrollController,
      itemCount: logs.length,
      itemBuilder: (context, index) {
        if (selectedOption != null &&
            logs[index].serviceName != selectedOption) {
          return const SizedBox.shrink();
        }

        final log = logs[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                log.dateTime.toString(),
                style: TextStyle(
                  color: colorScheme.hintColor,
                ),
              ),
              Wrap(
                children: [
                  Text(
                    '[${log.serviceName}]: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                    ),
                  ),
                  ReadMoreText(
                    _formatLog(log.message),
                    trimCollapsedText: context.t.misc.trailing_more,
                    trimExpandedText: context.t.misc.trailing_less,
                    trimMode: TrimMode.Line,
                    trimLines: 3,
                    style: TextStyle(
                      fontSize: 13,
                      color: switch (log.level) {
                        LogLevel.info => colorScheme.onSurface.withAlpha(222),
                        LogLevel.warning => Colors.yellow.withAlpha(222),
                        LogLevel.error => colorScheme.error,
                        LogLevel.verbose => colorScheme.onSurface.withAlpha(
                          222,
                        ),
                        LogLevel.debug => colorScheme.onSurface.withAlpha(222),
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

String _formatLog(String message) {
  final msg = tryDecodeFullUri(message).getOrElse(() => message);

  return msg;
}
