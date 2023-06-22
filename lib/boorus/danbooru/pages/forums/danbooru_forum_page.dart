// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/user_level_colors.dart';
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/compact_chip.dart';

class DanbooruForumPage extends ConsumerWidget {
  const DanbooruForumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(danbooruForumTopicsProvider(1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: topics.when(
        data: (topics) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                return Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (topic.isSticky)
                              Icon(
                                Icons.push_pin_outlined,
                                size: 20,
                                color: Theme.of(context).hintColor,
                              ),
                            if (topic.isLocked)
                              Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: Theme.of(context).hintColor,
                              ),
                            Expanded(
                                child: Text(
                              topic.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            )),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            CompactChip(
                              label: topic.creator.name.replaceAll('_', ' '),
                              backgroundColor: topic.creator.level.toColor(),
                            ),
                            const SizedBox(width: 8),
                            Text('Replies: ${topic.responseCount} | '),
                            Expanded(
                                child: Text(topic.createdAt
                                    .fuzzify(locale: context.locale))),
                          ],
                        )
                      ],
                    ),
                  ),
                  // ListTile(
                  //   minVerticalPadding: 0,
                  //   title: ,
                  //   subtitle: Padding(
                  //     padding: const EdgeInsets.symmetric(vertical: 4),
                  //     child: ,
                  //   ),
                  // ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}
