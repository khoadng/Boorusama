import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DanbooruForumPage extends ConsumerWidget {
  const DanbooruForumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(danbooruForumTopicsProvider(1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
      ),
      body: topics.when(
        data: (topics) {
          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return ListTile(
                title: Row(
                  children: [
                    if (topic.isSticky)
                      const Icon(Icons.push_pin_outlined, size: 16),
                    if (topic.isLocked)
                      const Icon(Icons.lock_outline, size: 16),
                    Expanded(child: Text(topic.title)),
                  ],
                ),
                subtitle: Text(topic.responseCount.toString()),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}
