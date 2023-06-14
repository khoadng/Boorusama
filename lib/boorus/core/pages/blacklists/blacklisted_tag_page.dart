// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/foundation/i18n.dart';

class BlacklistedTagPage extends ConsumerWidget {
  const BlacklistedTagPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('blacklist.manage.title').tr(),
      ),
      body: Builder(
        builder: (context) {
          final tags = ref.watch(globalBlacklistedTagsProvider);
          if (tags.isEmpty) {
            return Center(
              child: const Text('blacklist.manage.empty_blacklist').tr(),
            );
          }
          return ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return ListTile(
                title: Text(tag.name),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => ref
                      .read(globalBlacklistedTagsProvider.notifier)
                      .removeTag(tag),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          goToQuickSearchPage(
            context,
            ref: ref,
            onSelected: (tag) => ref
                .read(globalBlacklistedTagsProvider.notifier)
                .addTag(tag.value),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
