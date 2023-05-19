// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/downloads/post_file_name_generator.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';

final danbooruDownloadFileNameGeneratorProvider =
    Provider<FileNameGenerator>((ref) => BoorusamaStyledFileNameGenerator());
