// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

final favoriteTagRepoProvider =
    Provider<FavoriteTagRepository>((ref) => throw UnimplementedError());

final favoriteTagsProvider =
    NotifierProvider<FavoriteTagsNotifier, List<FavoriteTag>>(
  FavoriteTagsNotifier.new,
  dependencies: [
    favoriteTagRepoProvider,
  ],
);

class FavoriteTagsFilterScope extends ConsumerStatefulWidget {
  const FavoriteTagsFilterScope({
    super.key,
    this.initialValue,
    required this.builder,
  });

  final String? initialValue;

  final Widget Function(
    BuildContext context,
    List<FavoriteTag> tags,
    Set<String> labels,
    String selectedLabel,
  ) builder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FavoriteTagsFilterScopeState();
}

class _FavoriteTagsFilterScopeState
    extends ConsumerState<FavoriteTagsFilterScope> {
  late var selectedLabel = widget.initialValue ?? '';

  @override
  void didUpdateWidget(covariant FavoriteTagsFilterScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      selectedLabel = widget.initialValue ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(favoriteTagsProvider);
    final tagLabels = tags.expand((e) => e.labels ?? <String>[]).toSet();
    final filteredTags = tags.where((e) {
      if (selectedLabel.isEmpty) return true;

      return e.labels?.contains(selectedLabel) ?? false;
    }).toList();

    return widget.builder(
      context,
      filteredTags,
      tagLabels,
      selectedLabel,
    );
  }
}

class TagLabelsDropDownButton extends StatelessWidget {
  const TagLabelsDropDownButton({
    super.key,
    required this.tagLabels,
    required this.onChanged,
    required this.selectedLabel,
    this.backgroundColor,
    this.alignment,
  });

  final String selectedLabel;
  final Set<String> tagLabels;
  final ValueChanged<String> onChanged;
  final Color? backgroundColor;
  final AlignmentDirectional? alignment;

  @override
  Widget build(BuildContext context) {
    return OptionDropDownButton(
      backgroundColor: backgroundColor,
      alignment: alignment ?? AlignmentDirectional.centerEnd,
      value: selectedLabel,
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      items: tagLabels
          .prepend('')
          .map((value) => DropdownMenuItem(
                value: value,
                child: Text(value.isEmpty ? 'All' : value),
              ))
          .toList(),
    );
  }
}
