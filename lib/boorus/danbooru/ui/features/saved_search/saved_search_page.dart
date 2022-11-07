// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/saved_search/saved_search_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches/saved_searches.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/features/saved_search/widgets/edit_saved_search_sheet.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/error_box.dart';
import 'package:boorusama/core/ui/generic_no_data_box.dart';
import 'package:boorusama/core/ui/info_container.dart';

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
            onPressed: () => _onAddButtonPressed(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<SavedSearchBloc, SavedSearchState>(
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) {
            switch (state.status) {
              case LoadStatus.initial:
              case LoadStatus.loading:
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              case LoadStatus.success:
                return const _SuccessView();
              case LoadStatus.failure:
                return const ErrorBox();
            }
          },
        ),
      ),
    );
  }

  void _onAddButtonPressed(BuildContext context) {
    final bloc = context.read<SavedSearchBloc>();

    showMaterialModalBottomSheet(
      context: context,
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
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedSearchBloc, SavedSearchState>(
      buildWhen: (previous, current) => previous.data != current.data,
      builder: (context, state) {
        return state.data.isEmpty
            ? const GenericNoDataBox(
                text: "You haven't add any search yet",
              )
            : CustomScrollView(slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 15)),
                SliverToBoxAdapter(
                  child: InfoContainer(
                    contentBuilder: (context) => const Text(
                      "If you don't see any images, check if your query is correct. Also it might take a while for data to be populated.",
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${state.data.length} saved searches'.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverImplicitlyAnimatedList<SavedSearch>(
                  items: state.data,
                  areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
                  itemBuilder: _buildSearchItems,
                ),
              ]);
      },
    );
  }

  Widget _buildSearchItems(
    BuildContext context,
    Animation<double> animation,
    SavedSearch savedSearch,
    int index,
  ) {
    return SizeFadeTransition(
      sizeFraction: 0.7,
      curve: Curves.easeInOut,
      animation: animation,
      child: ListTile(
        title: Text(savedSearch.labels.join(' ')),
        subtitle: Text(savedSearch.query),
        trailing: savedSearch.readOnly
            ? null
            : IconButton(
                onPressed: () => _showEditSheet(
                  context,
                  savedSearch,
                ),
                icon: const Icon(Icons.more_vert),
              ),
        onTap: savedSearch.labels.isNotEmpty
            ? () => _goToSearchPage(
                  context,
                  query: 'search:${savedSearch.labels.first}',
                )
            : null,
        onLongPress: savedSearch.readOnly
            ? null
            : () => _showEditSheet(context, savedSearch),
      ),
    );
  }

  void _showEditSheet(BuildContext context, SavedSearch savedSearch) {
    final bloc = context.read<SavedSearchBloc>();
    showMaterialModalBottomSheet(
      context: context,
      builder: (_) => ModalSavedSearchAction(
        onDelete: () => bloc.add(SavedSearchDeleted(
          savedSearch: savedSearch,
        )),
        onEdit: () => showMaterialModalBottomSheet(
          context: context,
          backgroundColor: Theme.of(context).backgroundColor,
          builder: (_) => EditSavedSearchSheet(
            title: 'Update saved search',
            initialValue: savedSearch,
            onSubmit: (query, label) => bloc.add(SavedSearchUpdated(
              id: savedSearch.id,
              label: label,
              query: query,
              onUpdated: (data) => showSimpleSnackBar(
                context: context,
                duration: const Duration(
                  seconds: 1,
                ),
                content: const Text(
                  'Saved search has been updated',
                ),
              ),
            )),
          ),
        ),
      ),
    );
  }

  void _goToSearchPage(
    BuildContext context, {
    required String query,
  }) {
    AppRouter.router.navigateTo(
      context,
      '/posts/search',
      routeSettings: RouteSettings(arguments: [
        query,
      ]),
    );
  }
}

// ignore: prefer-single-widget-per-file
class ModalSavedSearchAction extends StatelessWidget {
  const ModalSavedSearchAction({
    super.key,
    this.onEdit,
    this.onDelete,
  });

  final void Function()? onEdit;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Edit'),
              leading: const Icon(Icons.edit),
              onTap: () {
                Navigator.of(context).pop();
                onEdit?.call();
              },
            ),
            ListTile(
              title: const Text('Delete'),
              leading: const Icon(Icons.clear),
              onTap: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
