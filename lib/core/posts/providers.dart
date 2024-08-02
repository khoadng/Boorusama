// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';

final emptyPostRepoProvider = Provider<PostRepository>(
  (ref) => EmptyPostRepository(),
);
