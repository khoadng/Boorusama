// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum PostDetailsOverlayInitialState {
  hide,
  show;

  factory PostDetailsOverlayInitialState.parse(dynamic value) =>
      switch (value) {
        'hide' || '0' || 0 => hide,
        'show' || '1' || 1 => show,
        _ => defaultValue,
      };

  static const PostDetailsOverlayInitialState defaultValue = show;

  bool get isHide => this == hide;

  String localize(BuildContext context) => switch (this) {
    show => context.t.settings.image_details.ui_overlay.show,
    hide => context.t.settings.image_details.ui_overlay.hide,
  };

  dynamic toData() => index;
}
