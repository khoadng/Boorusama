// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme.dart';

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
            icon: const Icon(Icons.close),
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
                color: getTagColor(tags[index].category, context.themeMode),
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
