// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:readmore/readmore.dart';

// Project imports:
import '../../../widgets/widgets.dart';
import '../../downloads/path.dart';
import '../../foundation/animations.dart';
import '../../foundation/clipboard.dart';
import '../../foundation/loggers.dart';
import '../../foundation/scrolling.dart';
import '../../foundation/toast.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';
import '../data/settings_providers.dart';

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
        message: 'settings.debug_logs.logs_copied'.tr(),
      );
    }

    return Scaffold(
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
  ) async =>
      tryGetDownloadDirectory().run().then(
            (value) => value.fold(
              (error) => showErrorToast(context, error.name),
              (directory) async {
                final file = File('${directory.path}/boorusama_logs.txt');
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
              },
            ),
          );

  Widget _buildBody(List<LogData> logs) {
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
                  color: Theme.of(context).colorScheme.hintColor,
                ),
              ),
              Wrap(
                children: [
                  Text(
                    '[${log.serviceName}]: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  ReadMoreText(
                    _formatLog(log.message),
                    trimExpandedText: ' less',
                    trimCollapsedText: ' more',
                    trimMode: TrimMode.Line,
                    trimLines: 3,
                    style: TextStyle(
                      fontSize: 13,
                      color: switch (log.level) {
                        LogLevel.info => Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(222),
                        LogLevel.warning => Colors.yellow.withAlpha(222),
                        LogLevel.error => Theme.of(context).colorScheme.error,
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
