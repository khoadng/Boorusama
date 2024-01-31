// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/backup/data_io_handler.dart';
import 'package:boorusama/core/feats/tags/favorite_tag_io_handler.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/pages/favorite_tags/favorite_tags_page.dart';

final favoriteTagRepoProvider =
    Provider<FavoriteTagRepository>((ref) => throw UnimplementedError());

final favoriteTagsProvider =
    NotifierProvider<FavoriteTagsNotifier, List<FavoriteTag>>(
  FavoriteTagsNotifier.new,
  dependencies: [
    favoriteTagRepoProvider,
  ],
);

final favoriteTagsIOHandlerProvider = Provider<FavoriteTagsIOHandler>(
  (ref) => FavoriteTagsIOHandler(
    handler: DataIOHandler.file(
      version: 1,
      deviceInfo: ref.watch(deviceInfoProvider),
      prefixName: 'boorusama_favorite_tags',
    ),
  ),
);

class FavoriteTagsFilterScope extends ConsumerStatefulWidget {
  const FavoriteTagsFilterScope({
    super.key,
    this.initialValue,
    this.filterQuery,
    this.sortType,
    required this.builder,
  });

  final String? initialValue;
  final String? filterQuery;
  final FavoriteTagsSortType? sortType;

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
  late var filterQuery = widget.filterQuery ?? '';
  late var sortType = widget.sortType ?? FavoriteTagsSortType.recentlyAdded;

  @override
  void didUpdateWidget(covariant FavoriteTagsFilterScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      selectedLabel = widget.initialValue ?? '';
    }

    if (oldWidget.filterQuery != widget.filterQuery) {
      filterQuery = widget.filterQuery ?? '';
    }

    if (oldWidget.sortType != widget.sortType) {
      sortType = widget.sortType ?? FavoriteTagsSortType.recentlyAdded;
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

    final filteredTagsWithQuery = filteredTags.where((e) {
      if (filterQuery.isEmpty) return true;

      return e.name.contains(filterQuery);
    }).toList();

    final sortedTags = filteredTagsWithQuery.toList()
      ..sort((a, b) {
        switch (sortType) {
          case FavoriteTagsSortType.recentlyAdded:
            return b.createdAt.compareTo(a.createdAt);
          case FavoriteTagsSortType.recentlyUpdated:
            if (a.updatedAt == null || b.updatedAt == null) return 0;

            return b.updatedAt!.compareTo(a.updatedAt!);
          case FavoriteTagsSortType.nameAZ:
            return a.name.compareTo(b.name);
          case FavoriteTagsSortType.nameZA:
            return b.name.compareTo(a.name);
          default:
            return 0;
        }
      });

    return widget.builder(
      context,
      sortedTags,
      tagLabels,
      tags.isEmpty ? '' : selectedLabel,
    );
  }
}
