// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:readmore/readmore.dart';

// Project imports:
import '../../../../foundation/clipboard.dart';
import '../../../../foundation/filesystem.dart';
import '../../../../foundation/loggers.dart';
import '../../../settings/providers.dart';
import '../../../widgets/widgets.dart';
import '../data/log_export.dart';
import '../providers/providers.dart';
import '../types/log_data.dart';
import '../types/write_log_status.dart';
import '../widgets/log_text_highlighting.dart';

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
    final redactSensitiveDetails = ref.watch(redactSensitiveLogsProvider);
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
              final fs = ref.read(appFileSystemProvider);
              await writeLogsToFile(
                fs,
                context,
                ref.read(appLoggerProvider).logs,
                reportContext: ref.read(appLoggerProvider).reportContext,
              );
            },
          ),
          KurumiPopupMenuButton(
            semanticLabel: 'Log options'.hc,
            items: [
              KurumiPopupMenuItem(
                title: Text(
                  redactSensitiveDetails
                      ? 'Include sensitive details'.hc
                      : 'Redact sensitive details'.hc,
                ),
                onTap: () async {
                  try {
                    await ref
                        .read(logOptionsProvider.notifier)
                        .setRedactSensitiveDetails(!redactSensitiveDetails);
                  } catch (_) {
                    if (context.mounted) {
                      Kurumi.showErrorToast(
                        context,
                        'Could not save log redaction preference'.hc,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: KurumiScrollToBottom(
        scrollController: scrollController,
        child: KurumiScrollToBottomButton(
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
  AppFileSystem fs,
  BuildContext context,
  List<LogData> logs, {
  Map<String, String> reportContext = const {},
}) async {
  final result = await writeLogs(fs, logs, context: reportContext);

  switch (result) {
    case WriteLogFailure(:final message):
      if (context.mounted) {
        Kurumi.showErrorToast(
          context,
          message,
        );
      }
    case WriteLogSuccess(:final filePath):
      if (context.mounted) {
        Kurumi.showSuccessToast(
          context,
          'Logs written to $filePath',
          duration: KurumiDurations.longToast,
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
    final colorScheme = Kurumi.themeOf(context).colorScheme;
    final colors = LogTextColors.forBrightness(colorScheme.brightness);
    final annotations = logTextAnnotations(colors);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      controller: scrollController,
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];

        if (selectedCategory != null && log.serviceName != selectedCategory) {
          return const SizedBox.shrink();
        }

        return SelectionArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  log.dateTime.toString(),
                  style: TextStyle(
                    color: colors.muted,
                  ),
                ),
                Wrap(
                  children: [
                    Text(
                      '[${log.serviceName}]: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    ReadMoreText(
                      log.message,
                      annotations: annotations,
                      trimCollapsedText: context.t.misc.trailing_more,
                      trimExpandedText: context.t.misc.trailing_less,
                      trimMode: TrimMode.Line,
                      trimLines: 3,
                      style: TextStyle(
                        fontSize: 13,
                        color: switch (log.level) {
                          LogLevel.warning => colors.warning,
                          LogLevel.error => colors.error,
                          _ => colors.text,
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
