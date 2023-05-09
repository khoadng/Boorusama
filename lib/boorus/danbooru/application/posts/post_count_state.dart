// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';

class PostCountState extends Equatable {
  const PostCountState(this.postCounts);
  final Map<String, int?> postCounts;

  factory PostCountState.initial() => const PostCountState({});

  @override
  List<Object> get props => [postCounts];
}

extension PostCountStateX on PostCountState {
  int? getPostCount(List<String> tags) {
    final key = generatePostCountKey(tags);
    return postCounts[key];
  }

  bool isLoading(List<String> tags) {
    final key = generatePostCountKey(tags);
    return !postCounts.containsKey(key);
  }

  // is empty if the post count is 0
  bool isEmpty(List<String> tags) {
    final key = generatePostCountKey(tags);
    return postCounts[key] == 0;
  }
}
