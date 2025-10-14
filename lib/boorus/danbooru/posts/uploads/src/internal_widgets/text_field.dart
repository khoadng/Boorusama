// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/search/suggestions/providers.dart';
import '../../../../../../core/search/suggestions/widgets.dart';
import '../../../../../../core/tags/autocompletes/types.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../pages/tag_edit_upload_text_controller.dart';

class TagEditUploadTextField extends StatelessWidget {
  const TagEditUploadTextField({
    super.key,
    required this.textEditingController,
  });

  final TagEditUploadTextController textEditingController;

  @override
  Widget build(BuildContext context) {
    return PortalTarget(
      anchor: const Aligned(
        follower: Alignment.bottomLeft,
        target: Alignment.topLeft,
      ),
      portalFollower: TagSuggestionsPortalFollower(
        controller: textEditingController,
        onSelected: (tag) {
          textEditingController.replaceLastWordWith(tag);
        },
      ),
      child: BooruTextFormField(
        controller: textEditingController,
        autocorrect: false,
        maxLines: 4,
        minLines: 4,
        validator: (p0) => null,
      ),
    );
  }
}

class TagSuggestionsPortalFollower extends ConsumerWidget {
  const TagSuggestionsPortalFollower({
    required this.onSelected,
    required this.controller,
    super.key,
  });

  final void Function(String tag) onSelected;
  final TagEditUploadTextController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;

    return ValueListenableBuilder<String?>(
      valueListenable: controller.lastWordNotifier,
      builder: (context, lastQuery, child) {
        final tags = lastQuery != null
            ? ref
                  .watch(suggestionProvider((config, lastQuery)))
                  .reversed
                  .toIList()
            : <AutocompleteData>[].lock;

        return tags.isEmpty
            ? const SizedBox.shrink()
            : Container(
                margin: const EdgeInsets.only(
                  bottom: 4,
                  left: 4,
                  right: 40,
                ),
                constraints: const BoxConstraints(
                  maxHeight: 200,
                ),
                width: MediaQuery.sizeOf(context).width,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: TagSuggestionItems(
                  config: config,
                  dense: true,
                  tags: tags,
                  reverse: true,
                  onItemTap: (tag) {
                    onSelected(tag.value);
                  },
                  currentQuery: lastQuery ?? '',
                ),
              );
      },
    );
  }
}
