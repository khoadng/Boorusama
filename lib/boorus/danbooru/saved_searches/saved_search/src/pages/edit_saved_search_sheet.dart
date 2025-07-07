// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/router.dart';
import '../../../../../../foundation/animations/constants.dart';
import '../../../../../../foundation/toast.dart';
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
    final navigatorContext = navigatorKey.currentContext;

    return SavedSearchSheet(
      initialValue: initialValue != null
          ? SavedSearch.empty().copyWith(query: initialValue)
          : null,
      onSubmit: (query, label) => notifier.create(
        query: query,
        label: label,
        onCreated: navigatorContext != null
            ? (data) => showSimpleSnackBar(
                context: navigatorContext,
                duration: AppDurations.shortToast,
                content: const Text('saved_search.saved_search_added').tr(),
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
    final navigatorContext = navigatorKey.currentContext;

    return SavedSearchSheet(
      title: 'saved_search.update_saved_search'.tr(),
      initialValue: savedSearch,
      onSubmit: (query, label) => notifier.edit(
        id: savedSearch.id,
        label: label,
        query: query,
        onUpdated: navigatorContext != null
            ? (data) => showSimpleSnackBar(
                context: navigatorContext,
                duration: AppDurations.shortToast,
                content: const Text(
                  'saved_search.saved_search_updated',
                ).tr(),
              )
            : null,
      ),
    );
  }
}
