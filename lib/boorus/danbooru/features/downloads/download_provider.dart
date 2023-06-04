// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/danbooru_file_name_generator.dart';
import 'package:boorusama/core/downloads/file_name_generator.dart';

final danbooruDownloadFileNameGeneratorProvider =
    Provider<FileNameGenerator>((ref) => BoorusamaStyledFileNameGenerator());
