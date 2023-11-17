// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/saved_searches/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/generic_no_data_box.dart';

class SavedSearchLandingView extends ConsumerWidget {
  const SavedSearchLandingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('saved_search.saved_search_feed').tr(),
        backgroundColor: context.theme.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 48,
                horizontal: 8,
              ),
              child: Column(
                children: [
                  GenericNoDataBox(
                    text: 'saved_search.empty_saved_search'.tr(),
                  ),
                  TextButton(
                    onPressed: () => launchExternalUrl(
                      Uri.parse(savedSearchHelpUrl),
                    ),
                    child: const Text('saved_search.saved_search_help').tr(),
                  ),
                  ElevatedButton(
                    onPressed: () => _onAddSearch(ref, context),
                    child: const Text('generic.action.add').tr(),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 2,
            ),
            ListTile(
              title: const Text('saved_search.saved_search_examples').tr(),
            ),
            _ExampleContainer(
              title: 'Follow artists',
              query: 'artistA or artistB or artistC or artistD',
              explain: 'Follow posts from artistA, artistB, artistC, artistD.',
              onTry: (query) => _onAddSearch(ref, context, query: query),
            ),
            _ExampleContainer(
              title: 'Follow specific characters from an artist',
              query: 'artistA (characterA or characterB or characterC)',
              explain:
                  'Follow posts that feature characterA or characterB or characterC from artistA.',
              onTry: (query) => _onAddSearch(ref, context, query: query),
            ),
            _ExampleContainer(
              title: 'Follow a specific thing',
              query:
                  'artistA ((characterA 1girl -ocean) or (characterB swimsuit))',
              explain:
                  'Follow posts that feature characterA with 1girl tag but without the ocean tag or characterB with swimsuit tag from artistA.',
              onTry: (query) => _onAddSearch(ref, context, query: query),
            ),
            _ExampleContainer(
              title: 'Follow random tags',
              query: 'artistA or characterB or scenery',
              explain:
                  'Follow posts that include artistA or characterB or scenery.',
              onTry: (query) => _onAddSearch(ref, context, query: query),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddSearch(
    WidgetRef ref,
    BuildContext context, {
    String? query,
  }) {
    goToSavedSearchCreatePage(
      ref,
      context,
      initialValue: SavedSearch.empty().copyWith(query: query),
    );
  }
}

class _ExampleContainer extends StatelessWidget {
  const _ExampleContainer({
    required this.title,
    required this.query,
    required this.explain,
    required this.onTry,
  });

  final String title;
  final String query;
  final String explain;
  final void Function(String query) onTry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  style: context.textTheme.titleLarge,
                ),
              ),
              Card(
                margin: const EdgeInsets.all(8),
                color: context.colorScheme.background,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Text(query),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(explain),
              ),
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => onTry(query),
                    child: const Text('saved_search.saved_search_try').tr(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
