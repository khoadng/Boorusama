// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

class PostGridConfigIconButton<T> extends ConsumerWidget {
  const PostGridConfigIconButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridSize = ref.watch(gridSizeSettingsProvider);
    final imageListType = ref.watch(imageListTypeSettingsProvider);
    final pageMode = ref.watch(pageModeSettingsProvider);

    return InkWell(
      onTap: () => showMaterialModalBottomSheet(
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
      child: const Icon(Icons.settings),
    );
  }
}

class PostGridActionSheet extends ConsumerWidget {
  const PostGridActionSheet({
    super.key,
    required this.onModeChanged,
    required this.onGridChanged,
    required this.pageMode,
    required this.gridSize,
    required this.imageListType,
    required this.onImageListChanged,
    this.popOnSelect = true,
  });

  final void Function(PageMode mode) onModeChanged;
  final void Function(GridSize grid) onGridChanged;
  final void Function(ImageListType imageListType) onImageListChanged;

  final PageMode pageMode;
  final GridSize gridSize;
  final ImageListType imageListType;
  final bool popOnSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var mobileButtons = [
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
          if (popOnSelect) context.navigator.pop();
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
          if (popOnSelect) context.navigator.pop();
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
          if (popOnSelect) context.navigator.pop();
          showMaterialModalBottomSheet(
            context: context,
            builder: (_) => OptionActionSheet(
              onChanged: onImageListChanged,
              optionName: (option) => option.name.sentenceCase,
              options: ImageListType.values,
            ),
          );
        },
      ),
    ];

    final desktopButtons = [
      DesktopPostGridConfigTile(
        title: 'Page mode',
        value: pageMode,
        onChanged: (value) => ref.setPageMode(value),
        items: PageMode.values,
        optionNameBuilder: (option) => option.name.sentenceCase,
      ),
      DesktopPostGridConfigTile(
        title: 'Grid',
        value: gridSize,
        onChanged: (value) => ref.setGridSize(value),
        items: GridSize.values,
        optionNameBuilder: (option) => option.name.sentenceCase,
      ),
      DesktopPostGridConfigTile(
        title: 'Image list',
        value: imageListType,
        onChanged: (value) => ref.setImageListType(value),
        items: ImageListType.values,
        optionNameBuilder: (option) => option.name.sentenceCase,
      ),
    ];

    return Material(
      color: Colors.transparent,
      child: ConditionalParentWidget(
        condition: isMobilePlatform(),
        conditionalBuilder: (child) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: isMobilePlatform() ? mobileButtons : desktopButtons,
        ),
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

class DesktopPostGridConfigTile<T> extends StatelessWidget {
  const DesktopPostGridConfigTile({
    super.key,
    required this.value,
    required this.title,
    required this.onChanged,
    required this.items,
    required this.optionNameBuilder,
  });

  final String title;
  final T value;
  final void Function(T value) onChanged;
  final List<T> items;
  final String Function(T option) optionNameBuilder;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: 80,
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(title),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minWidth: 150),
            child: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              onChanged: (value) => value != null ? onChanged(value) : null,
              value: value,
              items: items
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        optionNameBuilder(value),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
