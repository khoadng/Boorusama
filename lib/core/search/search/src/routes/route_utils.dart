// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../configs/config.dart';
import '../../../../router.dart';
import '../views/simple_tag_search_view.dart';

void goToSearchPage(
  BuildContext context, {
  String? tag,
}) {
  if (tag == null) {
    context.push(
      Uri(
        path: '/search',
      ).toString(),
    );
  } else {
    context.push(
      Uri(
        path: '/search',
        queryParameters: {
          kInitialQueryKey: tag,
        },
      ).toString(),
    );
  }
}

void goToQuickSearchPage(
  BuildContext context, {
  required WidgetRef ref,
  required void Function(String tag, bool isMultiple) onSelected,
  bool ensureValidTag = false,
  BooruConfigAuth? initialConfig,
  Widget Function(String text)? floatingActionButton,
  void Function(BuildContext context, String text, bool isMultiple)?
      onSubmitted,
  Widget Function(TextEditingController controller)? emptyBuilder,
}) {
  showSimpleTagSearchView(
    context,
    settings: const RouteSettings(
      name: RouterPageConstant.quickSearch,
    ),
    ensureValidTag: ensureValidTag,
    floatingActionButton: floatingActionButton,
    builder: (_, isMobile) => isMobile
        ? SimpleTagSearchView(
            initialConfig: initialConfig,
            onSubmitted: onSubmitted,
            ensureValidTag: ensureValidTag,
            floatingActionButton: floatingActionButton != null
                ? (text) => floatingActionButton.call(text)
                : null,
            onSelected: onSelected,
            emptyBuilder: emptyBuilder,
          )
        : SimpleTagSearchView(
            initialConfig: initialConfig,
            onSubmitted: onSubmitted,
            backButton: IconButton(
              splashRadius: 16,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Symbols.arrow_back),
            ),
            ensureValidTag: ensureValidTag,
            onSelected: onSelected,
            emptyBuilder: emptyBuilder,
          ),
  );
}
