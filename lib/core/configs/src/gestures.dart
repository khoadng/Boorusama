// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

enum GestureType {
  swipeUp,
  swipeDown,
  swipeLeft,
  swipeRight,
  doubleTap,
  longPress,
  tap,
}

class GestureConfig extends Equatable {
  const GestureConfig({
    required this.swipeUp,
    required this.swipeDown,
    required this.swipeLeft,
    required this.swipeRight,
    required this.doubleTap,
    required this.longPress,
    required this.tap,
  });

  const GestureConfig.undefined()
      : swipeUp = null,
        swipeDown = null,
        swipeLeft = null,
        swipeRight = null,
        doubleTap = null,
        longPress = null,
        tap = null;

  factory GestureConfig.fromJson(Map<String, dynamic> json) {
    return GestureConfig(
      swipeUp: json['swipeUp'] as String?,
      swipeDown: json['swipeDown'] as String?,
      swipeLeft: json['swipeLeft'] as String?,
      swipeRight: json['swipeRight'] as String?,
      doubleTap: json['doubleTap'] as String?,
      longPress: json['longPress'] as String?,
      tap: json['tap'] as String?,
    );
  }
  final String? swipeUp;
  final String? swipeDown;
  final String? swipeLeft;
  final String? swipeRight;
  final String? doubleTap;
  final String? longPress;
  final String? tap;

  GestureConfig copyWith({
    String? Function()? swipeUp,
    String? Function()? swipeDown,
    String? Function()? swipeLeft,
    String? Function()? swipeRight,
    String? Function()? doubleTap,
    String? Function()? longPress,
    String? Function()? tap,
  }) {
    return GestureConfig(
      swipeUp: swipeUp != null ? swipeUp() : this.swipeUp,
      swipeDown: swipeDown != null ? swipeDown() : this.swipeDown,
      swipeLeft: swipeLeft != null ? swipeLeft() : this.swipeLeft,
      swipeRight: swipeRight != null ? swipeRight() : this.swipeRight,
      doubleTap: doubleTap != null ? doubleTap() : this.doubleTap,
      longPress: longPress != null ? longPress() : this.longPress,
      tap: tap != null ? tap() : this.tap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (swipeUp != null) 'swipeUp': swipeUp,
      if (swipeDown != null) 'swipeDown': swipeDown,
      if (swipeLeft != null) 'swipeLeft': swipeLeft,
      if (swipeRight != null) 'swipeRight': swipeRight,
      if (doubleTap != null) 'doubleTap': doubleTap,
      if (longPress != null) 'longPress': longPress,
      if (tap != null) 'tap': tap,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [
        swipeUp,
        swipeDown,
        swipeLeft,
        swipeRight,
        doubleTap,
        longPress,
        tap,
      ];
}

class PostGestureConfig extends Equatable {
  const PostGestureConfig({
    required this.preview,
    required this.fullview,
  });

  const PostGestureConfig.undefined()
      : preview = null,
        fullview = null;

  factory PostGestureConfig.fromJson(Map<String, dynamic> json) {
    return PostGestureConfig(
      preview: json['preview'] != null
          ? GestureConfig.fromJson(json['preview'])
          : null,
      fullview: json['fullview'] != null
          ? GestureConfig.fromJson(json['fullview'])
          : null,
    );
  }

  // fromJsonString
  factory PostGestureConfig.fromJsonString(String? jsonString) {
    if (jsonString == null) {
      return const PostGestureConfig.undefined();
    }
    return PostGestureConfig.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }
  final GestureConfig? preview;
  final GestureConfig? fullview;

  PostGestureConfig copyWith({
    GestureConfig? Function()? preview,
    GestureConfig? Function()? fullview,
  }) {
    return PostGestureConfig(
      preview: preview != null ? preview() : this.preview,
      fullview: fullview != null ? fullview() : this.fullview,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (preview != null) 'preview': preview!.toJson(),
      if (fullview != null) 'fullview': fullview!.toJson(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  @override
  List<Object?> get props => [preview, fullview];
}

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
      _ => 'None'
    };

String describeImagePreviewQuickAction(String? action) => switch (action) {
      kDownloadAction => 'Download',
      kToggleBookmarkAction => 'Bookmark',
      kViewArtistAction => 'Artist',
      '' => 'None',
      _ => 'Use Default'
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

extension PostGestureConfigX on PostGestureConfig {
  PostGestureConfig withFulviewSwipeDown(String? value) {
    final fv = fullview ?? const GestureConfig.undefined();
    return copyWith(
      fullview: () => fv.copyWith(
        swipeDown: () => value,
      ),
    );
  }

  PostGestureConfig withFulviewDoubleTap(String? value) {
    final fv = fullview ?? const GestureConfig.undefined();
    return copyWith(
      fullview: () => fv.copyWith(
        doubleTap: () => value,
      ),
    );
  }

  PostGestureConfig withFulviewLongPress(String? value) {
    final fv = fullview ?? const GestureConfig.undefined();
    return copyWith(
      fullview: () => fv.copyWith(
        longPress: () => value,
      ),
    );
  }

  PostGestureConfig withPreviewTap(String? value) {
    final pv = preview ?? const GestureConfig.undefined();
    return copyWith(
      preview: () => pv.copyWith(
        tap: () => value,
      ),
    );
  }

  PostGestureConfig withPreviewLongPress(String? value) {
    final pv = preview ?? const GestureConfig.undefined();
    return copyWith(
      preview: () => pv.copyWith(
        longPress: () => value,
      ),
    );
  }
}

extension BooruBuilderGestures on GestureConfig? {
  bool canHandleGesture(GestureType gesture) {
    final gestures = this;
    if (gestures == null) return false;

    return switch (gesture) {
      GestureType.swipeDown => gestures.swipeDown != null,
      GestureType.swipeUp => gestures.swipeUp != null,
      GestureType.swipeLeft => gestures.swipeLeft != null,
      GestureType.swipeRight => gestures.swipeRight != null,
      GestureType.doubleTap => gestures.doubleTap != null,
      GestureType.longPress => gestures.longPress != null,
      GestureType.tap => gestures.tap != null,
    };
  }

  bool get canLongPress => canHandleGesture(GestureType.longPress);
  bool get canDoubleTap => canHandleGesture(GestureType.doubleTap);
  bool get canTap => canHandleGesture(GestureType.tap);
  bool get canSwipeDown => canHandleGesture(GestureType.swipeDown);
  bool get canSwipeUp => canHandleGesture(GestureType.swipeUp);
  bool get canSwipeLeft => canHandleGesture(GestureType.swipeLeft);
  bool get canSwipeRight => canHandleGesture(GestureType.swipeRight);
}
