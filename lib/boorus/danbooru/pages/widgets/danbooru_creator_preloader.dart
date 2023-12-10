// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users_provider.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';

class DanbooruCreatorPreloader extends ConsumerStatefulWidget {
  const DanbooruCreatorPreloader({
    super.key,
    required this.posts,
    required this.child,
  });

  final List<DanbooruPost> posts;
  final Widget child;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruCreatorPreloaderState();
}

class _DanbooruCreatorPreloaderState
    extends ConsumerState<DanbooruCreatorPreloader> {
  @override
  void initState() {
    super.initState();
    ref
        .read(danbooruCreatorsProvider(ref.readConfig).notifier)
        .load(widget.posts.extractEmbeddedUserIds());
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
