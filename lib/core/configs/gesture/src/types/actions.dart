// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../haptics/types.dart';

const kDownloadAction = 'download';
const kShareAction = 'share';
const kToggleBookmarkAction = 'toggleBookmark';
const kViewTagsAction = 'viewTags';
const kViewOriginalAction = 'viewOriginal';
const kOpenSourceAction = 'openSource';
const kStartSlideshowAction = 'startSlideshow';

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

const kDefaultFullviewActions = {
  ...kDefaultGestureActions,
  kStartSlideshowAction,
};

String describeDefaultGestureAction(String? action, BuildContext context) =>
    switch (action) {
      kDownloadAction => context.t.download.download,
      kShareAction => context.t.post.action.share,
      kToggleBookmarkAction => context.t.post.action.toggle_bookmark,
      kViewTagsAction => context.t.post.action.view_tags,
      kViewOriginalAction => context.t.post.action.view_original,
      kOpenSourceAction => context.t.post.action.view_in_browser,
      kStartSlideshowAction => context.t.post.action.slideshow,
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
  void Function()? onStartSlideshow,
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
    case kStartSlideshowAction:
      onStartSlideshow?.call();
    default:
      return false;
  }

  if (hapticLevel.isFull) {
    unawaited(HapticFeedback.selectionClick());
  }

  return true;
}
