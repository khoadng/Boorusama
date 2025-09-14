// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/widgets/generic_no_data_box.dart';
import '../../../../../../foundation/url_launcher.dart';
import '../../../../configs/providers.dart';
import '../../../saved_search/routes.dart';
import '../../../saved_search/saved_search.dart';

class SavedSearchLandingView extends ConsumerWidget {
  const SavedSearchLandingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.saved_search.saved_search_feed),
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
                    text: context.t.saved_search.empty_saved_search,
                  ),
                  if (!loginDetails.hasStrictSFW)
                    TextButton(
                      onPressed: () => launchExternalUrl(
                        Uri.parse(savedSearchHelpUrl),
                      ),
                      child: Text(context.t.saved_search.saved_search_help),
                    ),
                  FilledButton(
                    onPressed: () => _onAddSearch(ref, context),
                    child: Text(context.t.generic.action.add),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 2,
            ),
            ListTile(
              title: Text(context.t.saved_search.saved_search_examples),
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
      context,
      initialValue: query,
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
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Card(
                margin: const EdgeInsets.all(8),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 16,
                  ),
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
                  FilledButton(
                    onPressed: () => onTry(query),
                    child: Text(context.t.saved_search.saved_search_try),
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
