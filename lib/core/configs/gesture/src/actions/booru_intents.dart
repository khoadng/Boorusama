import '../../../../posts/post/post.dart';
import 'generic_intents.dart';

class UpvotePostIntent extends WidgetRefIntent {
  const UpvotePostIntent({required super.ref, required this.post});

  final Post post;
}

class DownvotePostIntent extends WidgetRefIntent {
  const DownvotePostIntent({required super.ref, required this.post});

  final Post post;
}

class EditPostIntent extends WidgetRefIntent {
  const EditPostIntent({required super.ref, required this.post});

  final Post post;
}
