// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../foundation/toast.dart';
import '../../widgets/selection_app_bar_builder.dart';
import '../../widgets/widgets.dart';
import '../sources/providers.dart';
import '../types/backup_data_source.dart';
import '../zip/providers.dart';

class ManualBackupPage extends ConsumerStatefulWidget {
  const ManualBackupPage({super.key});

  @override
  ConsumerState<ManualBackupPage> createState() => _ManualBackupPageState();
}

class _ManualBackupPageState extends ConsumerState<ManualBackupPage> {
  final SelectionModeController _selectionController =
      SelectionModeController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _selectionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registry = ref.watch(backupRegistryProvider);
    final sources = registry.getAllSources();

    ref.listen(
      backupProvider,
      (previous, next) {
        if (previous?.status != BackupStatus.completed &&
            next.status == BackupStatus.completed &&
            next.exportResult?.success == true) {
          _selectionController.disable();
        }
      },
    );

    return SelectionMode(
      controller: _selectionController,
      scrollController: _scrollController,
      options: const SelectionOptions(
        behavior: SelectionBehavior.manual,
      ),
      child: Scaffold(
        appBar: SelectionAppBarBuilder(
          builder: (context, controller, isSelectionMode) => !isSelectionMode
              ? AppBar(
                  title: Text(
                    context.t.settings.backup_and_restore.advanced_backup,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => controller.enable(),
                      child: Text(context.t.generic.action.select),
                    ),
                  ],
                )
              : AppBar(
                  title: ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) {
                      final selectedCount = controller.selection.length;
                      return Text(
                        selectedCount == 0
                            ? context.t.settings.backup_and_restore.select_items
                            : context
                                  .t
                                  .settings
                                  .backup_and_restore
                                  .items_selected
                                  .replaceAll(
                                    '{count}',
                                    selectedCount.toString(),
                                  ),
                      );
                    },
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => controller.disable(),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => controller.selectAll(
                        List.generate(sources.length, (index) => index),
                      ),
                      icon: const Icon(Symbols.select_all),
                    ),
                    IconButton(
                      onPressed: () => controller.deselectAll(),
                      icon: const Icon(Symbols.clear_all),
                    ),
                    TextButton(
                      onPressed: () => _selectionController.disable(),
                      child: Text(context.t.generic.done),
                    ),
                  ],
                ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: SelectionCanvas(
                onBackgroundTap: () {},
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: sources.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final source = sources[index];
                    return SelectableBuilder(
                      key: ValueKey(source.id),
                      index: index,
                      builder: (context, isSelected) => _SelectableBackupTile(
                        source: source,
                        index: index,
                        isSelected: isSelected,
                        isSelectionMode: _selectionController.isActive,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: SelectionConsumer(
                builder: (context, controller, _) {
                  final isSelectionMode = controller.isActive;
                  final backupState = ref.watch(backupProvider);
                  final isLoading = backupState.isActive;

                  if (!isSelectionMode) {
                    return const SizedBox.shrink();
                  }

                  return PrimaryButton(
                    onPressed: isLoading
                        ? null
                        : () => _performBulkBackup(context, sources),
                    child: isLoading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.t.settings.backup_and_restore.exporting,
                              ),
                            ],
                          )
                        : Text(context.t.settings.backup_and_restore.export),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performBulkBackup(
    BuildContext context,
    List<BackupDataSource> sources,
  ) async {
    final selectedSourceIds = _selectionController.selection
        .map((index) => sources[index].id)
        .toList();

    if (selectedSourceIds.isEmpty) {
      showErrorToast(
        context,
        context.t.settings.backup_and_restore.no_sources_selected,
      );
      return;
    }

    await ref
        .read(backupProvider.notifier)
        .exportToZip(
          context,
          selectedSourceIds,
        );
  }
}

class _SelectableBackupTile extends ConsumerWidget {
  const _SelectableBackupTile({
    required this.source,
    required this.index,
    required this.isSelected,
    required this.isSelectionMode,
  });

  final BackupDataSource source;
  final int index;
  final bool isSelected;
  final bool isSelectionMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = SelectionMode.of(context);

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: isSelectionMode ? 48 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: isSelectionMode ? 1.0 : 0.0,
            child: isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (value) => controller.toggleItem(index),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: isSelectionMode ? () => controller.toggleItem(index) : null,
            // ignore: use_decorated_box
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: source.buildTile(context),
            ),
          ),
        ),
      ],
    );
  }
}
