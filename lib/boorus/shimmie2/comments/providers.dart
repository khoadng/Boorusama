// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/comments/types.dart';
import '../../../core/configs/config/types.dart';
import '../posts/types.dart';
import 'types.dart';

final shimmie2CommentExtractorProvider =
    Provider.family<CommentExtractor<Shimmie2Post>, BooruConfigAuth>(
      (ref, config) => const Shimmie2CommentExtractor(),
    );
