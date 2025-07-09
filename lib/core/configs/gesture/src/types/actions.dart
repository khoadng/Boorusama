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

String describeDefaultGestureAction(String? action) => switch (action) {
  kDownloadAction => 'Download',
  kShareAction => 'Share',
  kToggleBookmarkAction => 'Toggle bookmark',
  kViewTagsAction => 'View tags',
  kViewOriginalAction => 'View original',
  kOpenSourceAction => 'Open source',
  kDefaultAction => 'Default',
  _ => 'None',
};

String describeImagePreviewQuickAction(String? action) => switch (action) {
  kDownloadAction => 'Download',
  kToggleBookmarkAction => 'Bookmark',
  kViewArtistAction => 'Artist',
  '' => 'None',
  _ => 'Use Default',
};

bool handleDefaultGestureAction(
  String? action, {
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

  return true;
}
