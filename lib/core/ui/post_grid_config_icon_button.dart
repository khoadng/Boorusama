// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';

// Project imports:
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';

class PostGridConfigIconButton<T> extends StatefulWidget {
  const PostGridConfigIconButton({super.key});

  @override
  State<PostGridConfigIconButton<T>> createState() =>
      _PostGridConfigIconButtonState();
}

class _PostGridConfigIconButtonState<T>
    extends State<PostGridConfigIconButton<T>> with SettingsCubitMixin {
  @override
  SettingsCubit get settingsCubit => context.read<SettingsCubit>();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showMaterialModalBottomSheet(
        context: context,
        builder: (_) => PostGridActionSheet(
          gridSize: settingsCubit.state.settings.gridSize,
          pageMode: settingsCubit.state.settings.contentOrganizationCategory ==
                  ContentOrganizationCategory.infiniteScroll
              ? PageMode.infinite
              : PageMode.paginated,
          imageListType: settingsCubit.state.settings.imageListType,
          onModeChanged: (mode) {
            setPageMode(mode == PageMode.infinite
                ? ContentOrganizationCategory.infiniteScroll
                : ContentOrganizationCategory.pagination);
          },
          onGridChanged: (grid) => setGridSize(grid),
          onImageListChanged: (imageListType) =>
              setImageListType(imageListType),
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
                    style: TextStyle(color: Theme.of(context).hintColor)),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
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
                    style: TextStyle(color: Theme.of(context).hintColor)),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
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
                    style: TextStyle(color: Theme.of(context).hintColor)),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
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
                    Navigator.of(context).pop();
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
                    Navigator.of(context).pop();
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
                  Navigator.of(context).pop();
                  onModeChanged(e);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
