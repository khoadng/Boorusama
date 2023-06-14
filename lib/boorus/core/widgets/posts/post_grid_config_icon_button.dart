// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/flutter.dart';

class PostGridConfigIconButton<T> extends ConsumerWidget {
  const PostGridConfigIconButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridSize = ref.watch(gridSizeSettingsProvider);
    final imageListType = ref.watch(imageListTypeSettingsProvider);
    final pageMode = ref.watch(pageModeSettingsProvider);

    return IconButton(
      onPressed: () => showMaterialModalBottomSheet(
        context: context,
        builder: (_) => PostGridActionSheet(
          gridSize: gridSize,
          pageMode: pageMode,
          imageListType: imageListType,
          onModeChanged: (mode) => ref.setPageMode(mode),
          onGridChanged: (grid) => ref.setGridSize(grid),
          onImageListChanged: (imageListType) =>
              ref.setImageListType(imageListType),
        ),
      ),
      icon: const Icon(Icons.settings),
    );
  }
}

class PostGridActionSheet extends StatelessWidget {
  const PostGridActionSheet({
    super.key,
    required this.onModeChanged,
    required this.onGridChanged,
    required this.pageMode,
    required this.gridSize,
    required this.imageListType,
    required this.onImageListChanged,
  });

  final void Function(PageMode mode) onModeChanged;
  final void Function(GridSize grid) onGridChanged;
  final void Function(ImageListType imageListType) onImageListChanged;

  final PageMode pageMode;
  final GridSize gridSize;
  final ImageListType imageListType;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Page mode'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(pageMode.name.sentenceCase,
                    style: TextStyle(color: context.theme.hintColor)),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              context.navigator.pop();
              showMaterialModalBottomSheet(
                context: context,
                builder: (_) => PageModeActionSheet(
                  onModeChanged: onModeChanged,
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Grid'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(gridSize.name.sentenceCase,
                    style: TextStyle(color: context.theme.hintColor)),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              context.navigator.pop();
              showMaterialModalBottomSheet(
                context: context,
                builder: (_) => GridSizeActionSheet(
                  onChanged: onGridChanged,
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Image list'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(imageListType.name.sentenceCase,
                    style: TextStyle(color: context.theme.hintColor)),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              context.navigator.pop();
              showMaterialModalBottomSheet(
                context: context,
                builder: (_) => OptionActionSheet<ImageListType>(
                  onChanged: onImageListChanged,
                  optionName: (option) => option.name.sentenceCase,
                  options: ImageListType.values,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Image list action sheet
class OptionActionSheet<T> extends StatelessWidget {
  const OptionActionSheet({
    super.key,
    required this.onChanged,
    required this.options,
    required this.optionName,
  });

  final void Function(T option) onChanged;
  final List<T> options;
  final String Function(T option) optionName;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map((e) => ListTile(
                  title: Text(optionName(e)),
                  onTap: () {
                    context.navigator.pop();
                    onChanged(e);
                  },
                ))
            .toList(),
      ),
    );
  }
}

class GridSizeActionSheet extends StatelessWidget {
  const GridSizeActionSheet({
    super.key,
    required this.onChanged,
  });

  final void Function(GridSize mode) onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: GridSize.values
            .map((e) => ListTile(
                  title: Text(e.name.sentenceCase),
                  onTap: () {
                    context.navigator.pop();
                    onChanged(e);
                  },
                ))
            .toList(),
      ),
    );
  }
}

// Page mode action sheet
class PageModeActionSheet extends StatelessWidget {
  const PageModeActionSheet({
    super.key,
    required this.onModeChanged,
  });

  final void Function(PageMode mode) onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: PageMode.values
            .map(
              (e) => ListTile(
                title: Text(e.name.sentenceCase),
                onTap: () {
                  context.navigator.pop();
                  onModeChanged(e);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
