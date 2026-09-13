// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../configs/config/types.dart';
import '../../../configs/create/create.dart';
import '../pages/settings_search_page.dart';
import '../widgets/settings_search_view.dart';
import '../types/settings_search_entry.dart';
import 'settings_page_route.dart';

Future<void> openSettingsSearch(
  BuildContext context, {
  BooruConfig? editingProfile,
  EditBooruConfigId? editingId,
  void Function(SettingsSearchEntry)? onOpenProfile,
}) {
  final inline = InlineSettingsSearch.maybeOf(context);
  if (inline != null) {
    inline.focusSearch();
    return Future.value();
  }
  final container = ProviderScope.containerOf(context);
  return pushSettingsPage(
    context,
    name: '/settings/find',
    builder: (_) => UncontrolledProviderScope(
      container: container,
      child: SettingsSearchPage(
        editingProfile: editingProfile,
        editingId: editingId,
        onOpenProfile: onOpenProfile,
      ),
    ),
  );
}
