// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/ui/features/saved_search/widgets/edit_saved_search_sheet.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/error_box.dart';

class SavedSearchPage extends StatelessWidget {
  const SavedSearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved search'),
        actions: [
          IconButton(
            onPressed: () {
              final bloc = context.read<SavedSearchBloc>();

              showAdaptiveBottomSheet(
                context,
                backgroundColor: Theme.of(context).backgroundColor,
                builder: (_) => EditSavedSearchSheet(
                  onSubmit: (query, label) => bloc.add(SavedSearchCreated(
                    query: query,
                    label: label,
                    onCreated: (data) => showSimpleSnackBar(
                      context: context,
                      duration: const Duration(seconds: 1),
                      content: const Text('Saved search has been added'),
                    ),
                  )),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<SavedSearchBloc, SavedSearchState>(
          builder: (context, state) {
            switch (state.status) {
              case LoadStatus.initial:
              case LoadStatus.loading:
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              case LoadStatus.success:
                return CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final savedSearch = state.data[index];

                          return ListTile(
                            title: Text(savedSearch.labels.join(' ')),
                            subtitle: Text(savedSearch.query),
                            trailing: IconButton(
                              onPressed: () => context
                                  .read<SavedSearchBloc>()
                                  .add(SavedSearchDeleted(
                                    savedSearch: savedSearch,
                                  )),
                              icon: const Icon(Icons.close),
                            ),
                            onTap: () {
                              final bloc = context.read<SavedSearchBloc>();

                              showAdaptiveBottomSheet(
                                context,
                                builder: (_) => EditSavedSearchSheet(
                                  title: 'Update saved search',
                                  initialValue: savedSearch,
                                  onSubmit: (query, label) => bloc.add(
                                    SavedSearchUpdated(
                                      id: savedSearch.id,
                                      label: label,
                                      query: query,
                                      onUpdated: (data) => showSimpleSnackBar(
                                        context: context,
                                        duration: const Duration(seconds: 1),
                                        content: const Text(
                                          'Saved search has been updated',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: state.data.length,
                      ),
                    ),
                  ],
                );
              case LoadStatus.failure:
                return const ErrorBox();
            }
          },
        ),
      ),
    );
  }
}
