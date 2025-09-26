// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../posts/post/post.dart';

abstract class WidgetRefIntent extends Intent {
  const WidgetRefIntent({required this.ref});

  final WidgetRef ref;
}

class DownloadPostIntent<T extends Post> extends WidgetRefIntent {
  const DownloadPostIntent({required super.ref, required this.post});

  final T post;
}

class SharePostIntent<T extends Post> extends WidgetRefIntent {
  const SharePostIntent({required super.ref, required this.post});

  final T post;
}

class BookmarkPostIntent<T extends Post> extends WidgetRefIntent {
  const BookmarkPostIntent({required super.ref, required this.post});

  final T post;
}

class ViewPostTagsIntent<T extends Post> extends WidgetRefIntent {
  const ViewPostTagsIntent({required super.ref, required this.post});

  final T post;
}

class ViewPostOriginalIntent<T extends Post> extends WidgetRefIntent {
  const ViewPostOriginalIntent({required super.ref, required this.post});

  final T post;
}

class OpenPostSourceIntent<T extends Post> extends Intent {
  const OpenPostSourceIntent({required this.post});

  final T post;
}

class FavoritePostIntent<T extends Post> extends WidgetRefIntent {
  const FavoritePostIntent({required super.ref, required this.post});

  final T post;
}

class ViewPostArtistIntent<T extends Post> extends WidgetRefIntent {
  const ViewPostArtistIntent({required super.ref, required this.post});

  final T post;
}

class PrintDebugInfoIntent extends Intent {
  const PrintDebugInfoIntent();
}
