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

class DownloadPostIntent extends WidgetRefIntent {
  const DownloadPostIntent({required super.ref, required this.post});

  final Post post;
}

class SharePostIntent extends WidgetRefIntent {
  const SharePostIntent({required super.ref, required this.post});

  final Post post;
}

class BookmarkPostIntent extends WidgetRefIntent {
  const BookmarkPostIntent({required super.ref, required this.post});

  final Post post;
}

class ViewPostTagsIntent extends WidgetRefIntent {
  const ViewPostTagsIntent({required super.ref, required this.post});

  final Post post;
}

class ViewPostOriginalIntent extends WidgetRefIntent {
  const ViewPostOriginalIntent({required super.ref, required this.post});

  final Post post;
}

class OpenPostSourceIntent extends Intent {
  const OpenPostSourceIntent({required this.post});

  final Post post;
}

class FavoritePostIntent extends WidgetRefIntent {
  const FavoritePostIntent({required super.ref, required this.post});

  final Post post;
}

class ViewPostArtistIntent extends WidgetRefIntent {
  const ViewPostArtistIntent({required super.ref, required this.post});

  final Post post;
}
