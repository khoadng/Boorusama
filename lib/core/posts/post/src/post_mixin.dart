// Project imports:
import 'post_tags.dart';

mixin TagListCheckMixin {
  Set<String> get tags;

  bool get isAI => tags.any(isAiTag);
}
