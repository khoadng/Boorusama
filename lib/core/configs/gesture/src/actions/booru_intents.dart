import 'generic_intents.dart';

class UpvotePostIntent<DanbooruPost> extends WidgetRefIntent {
  const UpvotePostIntent({required super.ref, required this.post});

  final DanbooruPost post;
}

class DownvotePostIntent<DanbooruPost> extends WidgetRefIntent {
  const DownvotePostIntent({required super.ref, required this.post});

  final DanbooruPost post;
}

class EditPostIntent<DanbooruPost> extends WidgetRefIntent {
  const EditPostIntent({required super.ref, required this.post});

  final DanbooruPost post;
}
