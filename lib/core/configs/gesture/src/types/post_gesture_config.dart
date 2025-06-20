// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'gesture_config.dart';

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
