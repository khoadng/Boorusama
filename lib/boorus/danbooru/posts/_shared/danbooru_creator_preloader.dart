// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/ref.dart';
import '../../users/creator/providers.dart';
import 'post_creator_preloadable.dart';

class DanbooruCreatorPreloader extends ConsumerStatefulWidget {
  const DanbooruCreatorPreloader({
    super.key,
    required this.preloadable,
    required this.child,
  });

  final PostCreatorsPreloadable preloadable;
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
        .read(danbooruCreatorsProvider(ref.readConfigAuth).notifier)
        .load(widget.preloadable.userIds);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
