// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:media_scanner/media_scanner.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads.dart';
import 'package:boorusama/boorus/danbooru/domain/downloads/post_file_name_generator.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/errors.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';
import 'package:boorusama/core/infra/downloads.dart';

class DanbooruBulkDownloadManagerBloc
    extends MobileBulkDownloadManagerBloc<DanbooruPost> {
  DanbooruBulkDownloadManagerBloc({
    required BuildContext context,
    required PostCountRepository postCountRepository,
    required DanbooruPostRepository postRepository,
    required UserAgentGenerator userAgentGenerator,
    required super.deviceInfo,
  }) : super(
            bulkPostDownloadBloc: DanbooruBulkDownloadBloc(
          downloader: CrossplatformBulkDownloader<DanbooruPost>(
            userAgentGenerator: userAgentGenerator,
            urlResolver: (item) => item.downloadUrl,
            fileNameResolver: (item) =>
                DanbooruMd5OnlyFileNameGenerator().generateFor(item),
            idResolver: (items) => items.id,
          ),
          postCountRepository: postCountRepository,
          postRepository: postRepository,
          errorTranslator: translateBooruError,
          onDownloadDone: (path) => MediaScanner.loadMedia(path: path),
        ));
}
