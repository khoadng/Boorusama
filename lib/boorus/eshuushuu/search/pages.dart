// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/listing/providers.dart';
import '../../../core/search/histories/providers.dart';
import '../../../core/search/search/routes.dart';
import '../../../core/search/search/widgets.dart';
import '../../../core/search/selected_tags/providers.dart';
import '../../../core/search/suggestions/providers.dart';
import '../posts/providers.dart';
import 'controllers.dart';
import 'providers.dart';
import 'widgets.dart';

class EshuushuuSearchPage extends ConsumerStatefulWidget {
  const EshuushuuSearchPage({
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  ConsumerState<EshuushuuSearchPage> createState() =>
      _EshuushuuSearchPageState();
}

class _EshuushuuSearchPageState extends ConsumerState<EshuushuuSearchPage> {
  late final SelectedTagController _tagsController;
  late final EshuushuuSearchController _controller;
  late final SelectionModeController _searchModeController;

  late final ValueNotifier<PostGridController?> _postController;

  @override
  void initState() {
    super.initState();

    _searchModeController = SelectionModeController();

    _tagsController = SelectedTagController(
      metatagExtractor: null,
    );

    _controller = EshuushuuSearchController(
      onSearch: () {
        ref
            .read(searchHistoryProvider.notifier)
            .addHistoryFromController(_tagsController);
      },
      getCurrentSelectedTagType: () =>
          ref.read(selectedTagTypeSelectorProvider).valueStr,
      tagsController: _tagsController,
    );

    _postController = ValueNotifier(null);
  }

  @override
  void dispose() {
    _tagsController.dispose();
    _controller.dispose();
    _searchModeController.dispose();
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watchConfigSearch;
    final postRepo = ref.watch(
      eshuushuuPostRepoProvider(search),
    );

    final suggestionNotifier = ref.watch(
      suggestionsNotifierProvider(search.auth).notifier,
    );

    ref.listen(
      selectedTagTypeSelectorProvider,
      (prev, next) {
        if (prev != next) {
          suggestionNotifier.setCategory(next.valueStr);
        }
      },
    );

    return RawSearchPageScaffold(
      params: widget.params,
      tagsController: _tagsController,
      controller: _controller,
      selectionModeController: _searchModeController,
      onQueryChanged: (query) {
        ref
            .read(suggestionsNotifierProvider(ref.readConfigAuth).notifier)
            .getSuggestions(query);
      },
      fetcher: (page, controller) => postRepo.getPostsFromController(
        controller.tagSet,
        page,
      ),
      landingView: EshuushuuMobileSearchLandingView(
        controller: _controller,
      ),
      searchSuggestions: DefaultSearchSuggestions(
        multiSelectController: _searchModeController,
        config: ref.watchConfigAuth,
      ),
      resultHeader: const SizedBox.shrink(),
      searchRegion: EshuushuuSearchRegion(
        controller: _controller,
        postController: _postController,
        initialQuery: widget.params.query,
      ),
      onPostControllerCreated: (controller) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _postController.value = controller;
        });
      },
    );
  }
}

class TagTypeSelectionSheet extends StatelessWidget {
  const TagTypeSelectionSheet({
    super.key,
    required this.tagName,
  });

  final String tagName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose the category for "$tagName"',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ...TagType.values.map(
          (type) => _TagTypeOptionTile(
            type: type,
            onTap: () => Navigator.of(context).pop(type),
          ),
        ),
      ],
    );
  }
}

class _TagTypeOptionTile extends StatelessWidget {
  const _TagTypeOptionTile({
    required this.type,
    required this.onTap,
  });

  final TagType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(12);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 12,
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: borderRadius,
            border: Border.all(
              width: 0.25,
              color: colorScheme.outlineVariant,
            ),
          ),
          child: Text(
            type.name.sentenceCase,
          ),
        ),
      ),
    );
  }
}
