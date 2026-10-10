// Package imports:
import 'package:equatable/equatable.dart';

enum ThumbnailAction { defaultAction, bookmark, download, artist }

final class ThumbnailActions extends Equatable {
  factory ThumbnailActions({
    ThumbnailAction? primary,
    ThumbnailAction? secondary,
  }) {
    if (primary == null && secondary != null ||
        primary != null && primary == secondary) {
      throw const FormatException(
        'Thumbnail actions require a primary action and must be distinct.',
      );
    }
    return ThumbnailActions._(primary, secondary);
  }

  const ThumbnailActions._(this.primary, this.secondary);
  const ThumbnailActions.defaultActions()
    : this._(ThumbnailAction.defaultAction, null);
  const ThumbnailActions.none() : this._(null, null);

  factory ThumbnailActions.fromConfigJson(Map<String, dynamic> json) {
    if (!json.containsKey('thumbnailActions')) {
      return ThumbnailActions(
        primary: switch (json['defaultPreviewImageButtonAction']) {
          '' => null,
          'toggleBookmark' => ThumbnailAction.bookmark,
          'download' => ThumbnailAction.download,
          'viewArtist' => ThumbnailAction.artist,
          _ => ThumbnailAction.defaultAction,
        },
      );
    }
    // Profiles can come from newer versions or backups, so anything unknown
    // is skipped instead of failing the whole profile.
    return switch (json['thumbnailActions']) {
      final List values when values.isEmpty => const ThumbnailActions.none(),
      final List values => switch (values.map(_parse).nonNulls.toSet()) {
        final actions when actions.isEmpty =>
          const ThumbnailActions.defaultActions(),
        final actions => ThumbnailActions(
          primary: actions.first,
          secondary: actions.skip(1).firstOrNull,
        ),
      },
      _ => const ThumbnailActions.defaultActions(),
    };
  }

  static ThumbnailAction? _parse(dynamic value) => switch (value) {
    'default' => ThumbnailAction.defaultAction,
    'bookmark' => ThumbnailAction.bookmark,
    'download' => ThumbnailAction.download,
    'artist' => ThumbnailAction.artist,
    _ => null,
  };

  final ThumbnailAction? primary;
  final ThumbnailAction? secondary;

  List<ThumbnailAction> get actions =>
      List.unmodifiable([?primary, ?secondary]);

  ThumbnailActions withPrimary(ThumbnailAction? action) => ThumbnailActions(
    primary: action,
    secondary: action == null || action == secondary ? null : secondary,
  );

  ThumbnailActions withSecondary(ThumbnailAction? action) =>
      ThumbnailActions(primary: primary, secondary: action);

  List<String> toJson() => actions
      .map(
        (action) => switch (action) {
          ThumbnailAction.defaultAction => 'default',
          _ => action.name,
        },
      )
      .toList();

  @override
  List<Object?> get props => [primary, secondary];
}
