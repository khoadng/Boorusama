// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/router.dart';
import '../providers/saved_searches_notifier.dart';
import '../types/saved_search.dart';
import 'saved_search_sheet.dart';

class CreateSavedSearchSheet extends ConsumerWidget {
  const CreateSavedSearchSheet({
    super.key,
    this.initialValue,
  });

  final String? initialValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(
      danbooruSavedSearchesProvider(ref.watchConfigAuth).notifier,
    );
    final navigatorContext = ref
        .watch(appNavigationProvider)
        .navigatorKey
        .currentContext;

    return SavedSearchSheet(
      initialValue: initialValue != null
          ? SavedSearch.empty().copyWith(query: initialValue)
          : null,
      onSubmit: (query, label) => notifier.create(
        query: query,
        label: label,
        onCreated: navigatorContext != null
            ? (data) => Kurumi.showSimpleSnackBar(
                context: navigatorContext,
                duration: KurumiDurations.shortToast,
                content: Text(context.t.saved_search.saved_search_added),
              )
            : null,
      ),
    );
  }
}

class EditSavedSearchSheet extends ConsumerWidget {
  const EditSavedSearchSheet({
    required this.savedSearch,
    super.key,
  });

  final SavedSearch savedSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(
      danbooruSavedSearchesProvider(ref.watchConfigAuth).notifier,
    );
    final navigatorContext = ref
        .watch(appNavigationProvider)
        .navigatorKey
        .currentContext;

    return SavedSearchSheet(
      title: context.t.saved_search.update_saved_search,
      initialValue: savedSearch,
      onSubmit: (query, label) => notifier.edit(
        id: savedSearch.id,
        label: label,
        query: query,
        onUpdated: navigatorContext != null
            ? (data) => Kurumi.showSimpleSnackBar(
                context: navigatorContext,
                duration: KurumiDurations.shortToast,
                content: Text(
                  context.t.saved_search.saved_search_updated,
                ),
              )
            : null,
      ),
    );
  }
}
