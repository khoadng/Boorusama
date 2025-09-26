// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../posts/post/post.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../types/actions.dart';
import 'booru_intents.dart';
import 'generic_intents.dart';
import 'post_actions_scope.dart';

class IntentBasedPostGestureHandler {
  const IntentBasedPostGestureHandler({
    this.customActions = const {},
  });

  final Map<String, bool Function(WidgetRef, String?, Post)> customActions;

  bool handle(WidgetRef ref, String? action, Post post) {
    // Try to handle with Intent system first
    final intent = _mapActionToIntent(action, ref, post);
    if (intent != null) {
      final handled = ref.invokePostAction(intent);
      if (handled) {
        _triggerHapticFeedback(ref);
        return true;
      }
    }

    // Fallback to custom actions
    for (final entry in customActions.entries) {
      if (entry.key == action) {
        final customAction = entry.value;
        if (customAction(ref, action, post)) {
          _triggerHapticFeedback(ref);
          return true;
        }
      }
    }

    return false;
  }

  Intent? _mapActionToIntent(String? action, WidgetRef ref, Post post) {
    return switch (action) {
      kDownloadAction => DownloadPostIntent(ref: ref, post: post),
      kShareAction => SharePostIntent(ref: ref, post: post),
      kToggleBookmarkAction => BookmarkPostIntent(ref: ref, post: post),
      kViewTagsAction => ViewPostTagsIntent(ref: ref, post: post),
      kViewOriginalAction => ViewPostOriginalIntent(ref: ref, post: post),
      kOpenSourceAction => OpenPostSourceIntent(post: post),
      kViewArtistAction => ViewPostArtistIntent(ref: ref, post: post),
      kToggleFavoriteAction => FavoritePostIntent(ref: ref, post: post),
      kUpvoteAction => UpvotePostIntent(ref: ref, post: post),
      kDownvoteAction => DownvotePostIntent(ref: ref, post: post),
      kEditAction => EditPostIntent(ref: ref, post: post),
      _ => null,
    };
  }

  void _triggerHapticFeedback(WidgetRef ref) {
    final hapticLevel = ref.read(hapticFeedbackLevelProvider);
    if (hapticLevel.isFull) {
      unawaited(HapticFeedback.selectionClick());
    }
  }
}
