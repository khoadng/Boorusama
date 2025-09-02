// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../providers/favorite_tags_notifier.dart';
import 'favorite_tag_label_details_page.dart';

class FavoriteTagLabelsPage extends ConsumerWidget {
  const FavoriteTagLabelsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(favoriteTagsProvider);
    final labels = ref.watch(favoriteTagLabelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Labels'.hc),
      ),
      body: labels.isNotEmpty
          ? ListView.builder(
              itemCount: labels.length,
              itemBuilder: (context, index) {
                final label = labels[index];
                final count = tags
                    .where((e) => e.labels?.contains(label) ?? false)
                    .length;
                return ListTile(
                  title: Text(label),
                  subtitle: Text(context.t.tags.counter(n: count)),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => FavoriteTagLabelDetailsPage(
                          label: label,
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : Center(
              child: Text(context.t.generic.errors.no_data),
            ),
    );
  }
}
