// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/downloads/file_name_generator.dart';
import 'package:boorusama/boorus/danbooru/feat/danbooru_file_name_generator.dart';

final danbooruDownloadFileNameGeneratorProvider =
    Provider<FileNameGenerator>((ref) => BoorusamaStyledFileNameGenerator());
