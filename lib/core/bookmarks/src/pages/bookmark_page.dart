// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../boorus/booru/types.dart';
import '../../../configs/create/create.dart';
import '../../../configs/create/routes.dart';
import '../../../configs/manage/providers.dart';
import '../../../configs/manage/src/types/utils.dart';
import '../../../widgets/widgets.dart';

class BookmarkPage extends ConsumerWidget {
  const BookmarkPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(booruConfigProvider);
    final bookmarkConfig = configs
        .where((config) => config.booruIdHint == BooruType.bookmarks.id)
        .firstOrNull;

    return CustomContextMenuOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.t.bookmark.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                bookmarkConfig != null ? Icons.bookmark : Icons.bookmark_border,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                bookmarkConfig != null
                    ? 'Bookmark Profile Found'
                    : 'No Bookmark Profile',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                bookmarkConfig != null
                    ? 'Open your bookmark profile to view saved bookmarks'
                    : 'Create a bookmark profile to manage your bookmarks',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (bookmarkConfig != null) {
                    // Navigate to bookmark profile using deeplink
                    final configFromLink = getConfigFromLink(
                      (id) => ref
                          .read(booruConfigProvider.notifier)
                          .findConfigById(id),
                      -1, // Use -1 as current config id to force navigation
                      '/?cid=${bookmarkConfig.id}',
                    );

                    if (configFromLink != null) {
                      context.go('/?cid=${bookmarkConfig.id}');
                    }
                  } else {
                    // Navigate to create new bookmark booru profile
                    goToAddBooruConfigPage(
                      ref,
                      initialConfigId: const EditBooruConfigId.newId(
                        booruType: BooruType.bookmarks,
                        url: '',
                      ),
                    );
                  }
                },
                child: Text(
                  bookmarkConfig != null
                      ? 'Open Bookmark Profile'
                      : 'Create Bookmark Profile',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
