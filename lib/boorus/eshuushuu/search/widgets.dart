// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/listing/providers.dart';
import '../../../core/search/search/widgets.dart';
import '../../../core/settings/providers.dart';
import '../../../core/widgets/widgets.dart';
import 'controllers.dart';
import 'providers.dart';

class EshuushuuSearchRegion extends ConsumerWidget {
  const EshuushuuSearchRegion({
    required this.controller,
    required this.postController,
    this.initialQuery,
    super.key,
  });

  final SearchPageController controller;
  final ValueNotifier<PostGridController?> postController;
  final String? initialQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoFocusSearchBar = ref.watch(
      settingsProvider.select((value) => value.autoFocusSearchBar),
    );
    final searchBarPosition = ref.watch(searchBarPositionProvider);

    return ValueListenableBuilder(
      valueListenable: postController,
      builder: (context, postControllerValue, _) {
        return RawSearchRegion(
          searchBarPosition: searchBarPosition,
          autoFocusSearchBar: autoFocusSearchBar,
          controller: controller,
          tagList: SelectedTagListWithData(
            controller: controller.tagsController,
            config: ref.watchConfig,
          ),
          innerSearchButton: DefaultInnerSearchButton(
            controller: controller,
            postController: postControllerValue,
          ),
          initialQuery: initialQuery,
          trailingSearchButton: Row(
            children: [
              const TagTypeSelectorButton(),
              DefaultTrailingSearchButton(
                controller: controller,
              ),
            ],
          ),
        );
      },
    );
  }
}

class TagTypeSelectorButton extends ConsumerWidget {
  const TagTypeSelectorButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OptionDropDownButton(
      alignment: AlignmentDirectional.centerStart,
      value: ref.watch(selectedTagTypeSelectorProvider),
      onChanged: (value) =>
          ref.read(selectedTagTypeSelectorProvider.notifier).state =
              value ?? TagType.tag,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      items: TagType.values
          .map(
            (value) => DropdownMenuItem(
              value: value,
              child: Text(value.name),
            ),
          )
          .toList(),
    );
  }
}

class EshuushuuMobileSearchLandingView extends StatelessWidget {
  const EshuushuuMobileSearchLandingView({
    super.key,
    required this.controller,
  });

  final EshuushuuSearchController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SearchLandingView(
        child: DefaultSearchLandingChildren(
          children: [
            DefaultFavoriteTagsSection(
              onTagTap: (value) {
                controller.tapFavTagWithDialog(context, value);
              },
            ),
            DefaultSearchHistorySection(
              onHistoryTap: (value) {
                controller.tapHistoryTagWithDialog(context, value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
