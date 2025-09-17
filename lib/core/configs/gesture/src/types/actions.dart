// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../settings/settings.dart';

const kDownloadAction = 'download';
const kShareAction = 'share';
const kToggleBookmarkAction = 'toggleBookmark';
const kViewTagsAction = 'viewTags';
const kViewOriginalAction = 'viewOriginal';
const kOpenSourceAction = 'openSource';

const kToggleFavoriteAction = 'toggleFavorite';
const kUpvoteAction = 'upvote';
const kDownvoteAction = 'downvote';
const kEditAction = 'edit';
const kViewArtistAction = 'viewArtist';

const kDefaultAction = 'default';

const kDefaultGestureActions = {
  null,
  kDownloadAction,
  kShareAction,
  kToggleBookmarkAction,
  kViewTagsAction,
  kViewOriginalAction,
  kOpenSourceAction,
};

String describeDefaultGestureAction(String? action, BuildContext context) =>
    switch (action) {
      kDownloadAction => context.t.download.download,
      kShareAction => context.t.post.action.share,
      kToggleBookmarkAction => context.t.post.action.toggle_bookmark,
      kViewTagsAction => context.t.post.action.view_tags,
      kViewOriginalAction => context.t.post.action.view_original,
      kOpenSourceAction => context.t.post.action.view_in_browser,
      kDefaultAction => context.t.post.action.use_default,
      _ => context.t.post.action.none,
    };

String describeImagePreviewQuickAction(String? action, BuildContext context) =>
    switch (action) {
      kDownloadAction => context.t.download.download,
      kToggleBookmarkAction => context.t.post.action.bookmark,
      kViewArtistAction => context.t.post.action.view_artist,
      '' => context.t.post.action.none,
      _ => context.t.post.action.use_default,
    };

bool handleDefaultGestureAction(
  String? action, {
  required HapticFeedbackLevel hapticLevel,
  void Function()? onDownload,
  void Function()? onShare,
  void Function()? onToggleBookmark,
  void Function()? onViewTags,
  void Function()? onViewOriginal,
  void Function()? onOpenSource,
}) {
  switch (action) {
    case kDownloadAction:
      onDownload?.call();
    case kShareAction:
      onShare?.call();
    case kViewTagsAction:
      onViewTags?.call();
    case kToggleBookmarkAction:
      onToggleBookmark?.call();
    case kViewOriginalAction:
      onViewOriginal?.call();
    case kOpenSourceAction:
      onOpenSource?.call();
    default:
      return false;
  }

  if (hapticLevel.isFull) {
    unawaited(HapticFeedback.selectionClick());
  }

  return true;
}
