enum ImageQuality {
  automatic,
  low,
  high,
  original,
  highest,
}

enum GridSize {
  small,
  normal,
  large,
  tiny,
  micro,
}

enum ImageListType {
  standard,
  masonry,
  classic,
}

enum DataCollectingStatus {
  allow,
  prohibit,
}

enum PageMode {
  infinite,
  paginated,
}

enum DownloadQuality {
  original,
  sample,
  preview,
}

enum AppLockType {
  none,
  biometrics,
  pin,
}

enum BookmarkFilterType {
  none,
  hideAll,
}

enum PageIndicatorPosition {
  bottom,
  top,
  both,
}

enum PostDetailsOverlayInitialState {
  hide,
  show,
}

enum BooruConfigSelectorPosition {
  side,
  bottom,
}

enum BooruConfigScrollDirection {
  normal,
  reversed,
}

enum BooruConfigLabelVisibility {
  always,
  never,
}

enum MediaBlurCondition {
  none,
  explicitOnly,
}

enum SlideshowTransitionType {
  none,
  natural,
}

enum DownloadFileExistedBehavior {
  appDecide,
  skip,
  overwrite,
}

enum VideoAudioDefaultState {
  unspecified,
  unmute,
  mute,
}

enum SlideshowDirection {
  forward,
  backward,
  random,
}

enum AnimatedPostsDefaultState {
  autoplay,
  static,
}

extension ImageQualityX on ImageQuality {
  bool get isHighres => switch (this) {
    ImageQuality.high => true,
    ImageQuality.highest => true,
    _ => false,
  };
}

extension PageIndicatorPositionX on PageIndicatorPosition {
  bool get isVisibleAtBottom =>
      this == PageIndicatorPosition.bottom ||
      this == PageIndicatorPosition.both;
  bool get isVisibleAtTop =>
      this == PageIndicatorPosition.top || this == PageIndicatorPosition.both;
}

const kSortedGridSizes = [
  GridSize.micro,
  GridSize.tiny,
  GridSize.small,
  GridSize.normal,
  GridSize.large,
];


enum SearchBarScrollBehavior {
  autoHide,
  persistent,
}

enum SearchBarPosition {
  top,
  bottom,
}

enum HapticFeedbackLevel {
  none,
  reduced,
  balanced,
  full,
}

extension HapticFeedbackLevelX on HapticFeedbackLevel {
  bool get isReducedOrAbove => switch (this) {
    HapticFeedbackLevel.reduced ||
    HapticFeedbackLevel.balanced ||
    HapticFeedbackLevel.full => true,
    _ => false,
  };
  bool get isBalanceAndAbove => switch (this) {
    HapticFeedbackLevel.balanced || HapticFeedbackLevel.full => true,
    _ => false,
  };

  bool get isFull => this == HapticFeedbackLevel.full;
}

enum PostDetailsSwipeMode {
  horizontal,
  vertical,
}
