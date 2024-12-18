// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../saved_search/providers.dart';
import '../../../saved_search/routes.dart';
import '../../../saved_search/saved_search.dart';
import '../widgets/modal_saved_search_action.dart';

class SavedSearchQuickEditSheet extends ConsumerWidget {
  const SavedSearchQuickEditSheet({
    super.key,
    required this.savedSearch,
  });

  final SavedSearch savedSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ModalSavedSearchAction(
      onDelete: () => ref
          .read(danbooruSavedSearchesProvider(ref.readConfigAuth).notifier)
          .delete(savedSearch: savedSearch),
      onEdit: () => goToSavedSearchPatchPage(context, savedSearch),
    );
  }
}
