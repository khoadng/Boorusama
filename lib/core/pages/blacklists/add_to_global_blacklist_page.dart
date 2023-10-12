// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/flutter.dart';

class AddToGlobalBlacklistPage extends ConsumerWidget {
  const AddToGlobalBlacklistPage({
    super.key,
    required this.tags,
  });

  final List<Tag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: context.navigator.pop,
            icon: const Icon(Icons.close),
          ),
        ],
        toolbarHeight: kToolbarHeight * 0.75,
        automaticallyImplyLeading: false,
        title: const Text('Add to global blacklist'),
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
              ref.read(globalBlacklistedTagsProvider.notifier).addTagWithToast(
                    tag.rawName,
                  );
            }),
        itemCount: tags.length,
      ),
    );
  }
}
