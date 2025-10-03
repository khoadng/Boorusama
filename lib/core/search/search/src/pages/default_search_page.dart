// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../configs/config/providers.dart';
import '../../../../posts/post/providers.dart';
import '../widgets/search_page_scaffold.dart';
import 'search_page.dart';

class DefaultSearchPage extends ConsumerWidget {
  const DefaultSearchPage({
    required this.params,
    super.key,
  });

  final SearchParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postRepo = ref.watch(postRepoProvider(ref.watchConfigSearch));

    return SearchPageScaffold(
      params: params,
      fetcher: (page, controler) => postRepo.getPostsFromController(
        controler.tagSet,
        page,
      ),
    );
  }
}
