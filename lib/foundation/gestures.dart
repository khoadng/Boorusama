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
  final String? swipeUp;
  final String? swipeDown;
  final String? swipeLeft;
  final String? swipeRight;
  final String? doubleTap;
  final String? longPress;
  final String? tap;

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
  final GestureConfig? preview;
  final GestureConfig? fullview;

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
        jsonDecode(jsonString) as Map<String, dynamic>);
  }

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
const kGoBackAction = 'goBack';
const kToggleBookmarkAction = 'toggleBookmark';

const kToggleFavoriteAction = 'toggleFavorite';
const kUpvoteAction = 'upvote';
const kDownvoteAction = 'downvote';

const kDefaultGestureActions = {
  null,
  kDownloadAction,
  kShareAction,
  kGoBackAction,
  kToggleBookmarkAction,
};

String describeDefaultGestureAction(String? action) => switch (action) {
      kDownloadAction => 'Download',
      kShareAction => 'Share',
      kGoBackAction => 'Go back',
      kToggleBookmarkAction => 'Toggle bookmark',
      _ => 'None'
    };

bool handleDefaultGestureAction(
  String? action, {
  void Function()? onDownload,
  void Function()? onShare,
  void Function()? onGoBack,
  void Function()? onToggleBookmark,
}) {
  switch (action) {
    case kDownloadAction:
      onDownload?.call();
      break;
    case kShareAction:
      onShare?.call();
      break;
    case kGoBackAction:
      onGoBack?.call();
      break;
    case kToggleBookmarkAction:
      onToggleBookmark?.call();
      break;
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
}
