// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/simple_tag_search_view.dart';
import 'package:boorusama/core/application/tags/tags.dart';

class AddTagButton extends StatelessWidget {
  const AddTagButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 28,
      splashRadius: 20,
      onPressed: () {
        final bloc = context.read<FavoriteTagBloc>();
        showBarModalBottomSheet(
          context: context,
          duration: const Duration(milliseconds: 200),
          builder: (context) => SimpleTagSearchView(
            ensureValidTag: false,
            floatingActionButton: (text) => text.isEmpty
                ? const SizedBox.shrink()
                : FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      bloc.add(FavoriteTagAdded(tag: text));
                    },
                    child: const Icon(Icons.add),
                  ),
            onSelected: (tag) {
              bloc.add(FavoriteTagAdded(tag: tag.value));
            },
          ),
        );
      },
      icon: const Icon(Icons.add),
    );
  }
}
