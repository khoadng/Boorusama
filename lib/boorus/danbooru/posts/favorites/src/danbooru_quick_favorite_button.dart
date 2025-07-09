// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import '../../../../../core/posts/favorites/providers.dart';
import '../../../../../core/posts/favorites/widgets.dart';
import '../../post/post.dart';

class DanbooruQuickFavoriteButton extends ConsumerWidget {
  const DanbooruQuickFavoriteButton({
    required this.post,
    super.key,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfigAuth;
    final notifier = ref.watch(favoritesProvider(config).notifier);
    final isFaved = post.isBanned
        ? false
        : ref.watch(favoriteProvider((config, post.id)));

    return QuickFavoriteButton(
      isFaved: isFaved,
      onFavToggle: (isFaved) async {
        if (!isFaved) {
          unawaited(notifier.remove(post.id));
        } else {
          unawaited(notifier.add(post.id));
        }
      },
    );
  }
}
