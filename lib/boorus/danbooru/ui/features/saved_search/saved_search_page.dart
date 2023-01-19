// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:easy_localization/easy_localization.dart';
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

class SavedSearchPage extends StatelessWidget {
  const SavedSearchPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('saved_search.saved_search').tr(),
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

    if (isMobilePlatform()) {
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
              content: const Text('saved_search.saved_search_added').tr(),
            ),
          )),
        ),
      );
    } else {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        pageBuilder: (context, _, __) {
          return Dialog(
            backgroundColor: Theme.of(context).backgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              margin: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: EditSavedSearchSheet(
                onSubmit: (query, label) => bloc.add(SavedSearchCreated(
                  query: query,
                  label: label,
                  onCreated: (data) => showSimpleSnackBar(
                    context: context,
                    duration: const Duration(seconds: 1),
                    content: const Text('saved_search.saved_search_added').tr(),
                  ),
                )),
              ),
            ),
          );
        },
      );
    }
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
            ? GenericNoDataBox(
                text: 'saved_search.empty_saved_search'.tr(),
              )
            : CustomScrollView(slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 15)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'saved_search.saved_search_counter'
                              .plural(state.data.length)
                              .toUpperCase(),
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
    return ListTile(
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
          ? () => goToSearchPage(
                context,
                tag: 'search:${savedSearch.labels.first}',
              )
          : null,
      onLongPress: savedSearch.readOnly
          ? null
          : () => _showEditSheet(context, savedSearch),
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
            title: 'saved_search.update_saved_search'.tr(),
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
                  'saved_search.saved_search_updated',
                ).tr(),
              ),
            )),
          ),
        ),
      ),
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
              title: const Text('generic.action.edit').tr(),
              leading: const Icon(Icons.edit),
              onTap: () {
                Navigator.of(context).pop();
                onEdit?.call();
              },
            ),
            ListTile(
              title: const Text('generic.action.delete').tr(),
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
