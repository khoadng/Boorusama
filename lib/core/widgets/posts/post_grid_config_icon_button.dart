// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

class PostGridConfigIconButton<T> extends ConsumerWidget {
  const PostGridConfigIconButton({
    super.key,
    required this.postController,
  });

  final PostGridController<Post> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridSize = ref.watch(gridSizeSettingsProvider);
    final imageListType = ref.watch(imageListTypeSettingsProvider);
    final pageMode = ref.watch(pageModeSettingsProvider);
    final imageQuality = ref.watch(imageQualitySettingsProvider);

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () => showMaterialModalBottomSheet(
        context: context,
        builder: (_) => PostGridActionSheet(
          postController: postController,
          gridSize: gridSize,
          pageMode: pageMode,
          imageListType: imageListType,
          imageQuality: imageQuality,
          onModeChanged: (mode) => ref.setPageMode(mode),
          onGridChanged: (grid) => ref.setGridSize(grid),
          onImageListChanged: (imageListType) =>
              ref.setImageListType(imageListType),
          onImageQualityChanged: (imageQuality) =>
              ref.setImageQuality(imageQuality),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        child: const Icon(
          Symbols.settings,
          fill: 1,
        ),
      ),
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
    required this.imageQuality,
    required this.onImageListChanged,
    required this.onImageQualityChanged,
    this.popOnSelect = true,
    required this.postController,
  });

  final void Function(PageMode mode) onModeChanged;
  final void Function(GridSize grid) onGridChanged;
  final void Function(ImageListType imageListType) onImageListChanged;
  final void Function(ImageQuality imageQuality) onImageQualityChanged;

  final PageMode pageMode;
  final GridSize gridSize;
  final ImageListType imageListType;
  final ImageQuality imageQuality;
  final bool popOnSelect;
  final PostGridController<Post> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postStatsPageBuilder =
        ref.watchBooruBuilder(ref.watchConfig)?.postStatisticsPageBuilder;

    var mobileButtons = [
      MobilePostGridConfigTile(
        value: pageMode.localize().tr(),
        title: 'settings.result_layout.result_layout'.tr(),
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
      MobilePostGridConfigTile(
        value: gridSize.localize().tr(),
        title: 'settings.image_grid.image_grid'.tr(),
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
      MobilePostGridConfigTile(
        value: imageListType.localize().tr(),
        title: 'settings.image_list.image_list'.tr(),
        onTap: () {
          if (popOnSelect) context.navigator.pop();
          showMaterialModalBottomSheet(
            context: context,
            builder: (_) => OptionActionSheet(
              onChanged: onImageListChanged,
              optionName: (option) => option.localize().tr(),
              options: ImageListType.values,
            ),
          );
        },
      ),
      MobilePostGridConfigTile(
        value: imageQuality.localize().tr(),
        title: 'settings.image_grid.image_quality.image_quality'.tr(),
        onTap: () {
          if (popOnSelect) context.navigator.pop();
          showMaterialModalBottomSheet(
            context: context,
            builder: (_) => OptionActionSheet(
              onChanged: onImageQualityChanged,
              optionName: (option) => option.localize().tr(),
              options: [...ImageQuality.values]..remove(ImageQuality.original),
            ),
          );
        },
      ),
      if (postStatsPageBuilder != null && postController.items.isNotEmpty) ...[
        const Divider(),
        ListTile(
          title: const Text('Stats for nerds'),
          onTap: () {
            context.navigator.pop();
            showMaterialModalBottomSheet(
              context: context,
              duration: const Duration(milliseconds: 250),
              builder: (_) => postStatsPageBuilder(
                context,
                postController.items,
              ),
            );
          },
        ),
      ],
    ];

    final desktopButtons = [
      DesktopPostGridConfigTile(
        title: 'settings.result_layout.result_layout'.tr(),
        value: pageMode,
        onChanged: (value) => ref.setPageMode(value),
        items: PageMode.values,
        optionNameBuilder: (option) => option.localize().tr(),
      ),
      DesktopPostGridConfigTile(
        title: 'settings.image_grid.image_grid'.tr(),
        value: gridSize,
        onChanged: (value) => ref.setGridSize(value),
        items: GridSize.values,
        optionNameBuilder: (option) => option.name.sentenceCase,
      ),
      DesktopPostGridConfigTile(
        title: 'settings.image_list.image_list'.tr(),
        value: imageListType,
        onChanged: (value) => ref.setImageListType(value),
        items: ImageListType.values,
        optionNameBuilder: (option) => option.name.sentenceCase,
      ),
      DesktopPostGridConfigTile(
        title: 'settings.image_grid.image_quality.image_quality'.tr(),
        value: imageQuality,
        onChanged: (value) => ref.setImageQuality(value),
        items: [...ImageQuality.values]..remove(ImageQuality.original),
        optionNameBuilder: (option) => option.name.sentenceCase,
      ),
    ];

    return Material(
      color: isDesktopPlatform()
          ? context.colorScheme.surface
          : context.colorScheme.secondaryContainer,
      child: ConditionalParentWidget(
        condition: isMobilePlatform(),
        conditionalBuilder: (child) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

class MobilePostGridConfigTile extends StatelessWidget {
  const MobilePostGridConfigTile({
    super.key,
    required this.value,
    required this.title,
    required this.onTap,
  });

  final String title;
  final String value;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: context.theme.hintColor,
              fontSize: 14,
            ),
          ),
          const Icon(Symbols.chevron_right),
        ],
      ),
      onTap: onTap,
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
      color: context.colorScheme.secondaryContainer,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
      color: context.colorScheme.secondaryContainer,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: GridSize.values
              .map((e) => ListTile(
                    title: Text(e.localize()).tr(),
                    onTap: () {
                      context.navigator.pop();
                      onChanged(e);
                    },
                  ))
              .toList(),
        ),
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
      color: context.colorScheme.secondaryContainer,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: PageMode.values
              .map(
                (e) => ListTile(
                  title: Text(e.localize()).tr(),
                  onTap: () {
                    context.navigator.pop();
                    onModeChanged(e);
                  },
                ),
              )
              .toList(),
        ),
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
