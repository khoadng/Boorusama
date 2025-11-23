// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:readmore/readmore.dart';

// Project imports:
import '../../../../foundation/clipboard.dart';
import '../../../../foundation/loggers.dart';
import '../../../../foundation/scrolling.dart';
import '../../foundation/animations/constants.dart';
import '../../foundation/toast.dart';
import '../settings/providers.dart';
import '../themes/theme/types.dart';
import '../widgets/widgets.dart';
import 'providers.dart';
import 'types.dart';

class DebugLogsPage extends ConsumerStatefulWidget {
  const DebugLogsPage({
    super.key,
  });

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
    final selectedCategory = ref.watch(selectedDebugLogCategoryProvider);

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
          const _DebugCategorySelector(),
          Expanded(
            child: _LogsList(
              logs: logs,
              selectedCategory: selectedCategory,
              scrollController: scrollController,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> writeLogsToFile(
  BuildContext context,
  List<LogData> logs,
) async {
  final result = await writeLogs(logs);

  switch (result) {
    case WriteLogFailure(:final message):
      if (context.mounted) {
        showErrorToast(
          context,
          message,
        );
      }
    case WriteLogSuccess(:final filePath):
      if (context.mounted) {
        showSuccessToast(
          context,
          'Logs written to $filePath',
          duration: AppDurations.longToast,
        );
      }
  }
}

class _DebugCategorySelector extends ConsumerWidget {
  const _DebugCategorySelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(debugLogsProvider);
    final categories = logs.map((e) => e.serviceName).toSet().toList();
    final selectedCategory = ref.watch(selectedDebugLogCategoryProvider);

    return ChoiceOptionSelectorList(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      options: categories,
      selectedOption: selectedCategory,
      searchable: false,
      optionLabelBuilder: (option) => option ?? 'All',
      onSelected: (value) {
        ref.read(selectedDebugLogCategoryProvider.notifier).state = value;
      },
    );
  }
}

class _LogsList extends StatelessWidget {
  const _LogsList({
    required this.logs,
    required this.selectedCategory,
    required this.scrollController,
  });

  final List<LogData> logs;
  final String? selectedCategory;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      controller: scrollController,
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];

        if (selectedCategory != null && log.serviceName != selectedCategory) {
          return const SizedBox.shrink();
        }

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
                    log.format(),
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
