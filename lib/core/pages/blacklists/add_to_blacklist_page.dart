// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/flutter.dart';

class AddToBlacklistPage extends ConsumerWidget {
  const AddToBlacklistPage({
    super.key,
    required this.tags,
    required this.onSelected,
  });

  final List<Tag> tags;
  final void Function(Tag tag) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: context.navigator.pop,
            icon: const Icon(Symbols.close),
          ),
        ],
        toolbarHeight: kToolbarHeight * 0.75,
        automaticallyImplyLeading: false,
        title: const Text('Add to blacklist'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
            title: Text(
              tags[index].displayName,
              style: TextStyle(
                color: ref.getTagColor(context, tags[index].category.name),
              ),
            ),
            onTap: () {
              final tag = tags[index];
              context.navigator.pop();
              onSelected(tag);
            }),
        itemCount: tags.length,
      ),
    );
  }
}
