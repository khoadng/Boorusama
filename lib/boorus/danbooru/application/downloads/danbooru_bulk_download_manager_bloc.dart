// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_scanner/media_scanner.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/downloads.dart';
import 'package:boorusama/boorus/danbooru/domain/downloads/post_file_name_generator.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/errors.dart';
import 'package:boorusama/boorus/danbooru/infra/services/bulk_downloader.dart';
import 'package:boorusama/core/application/downloads.dart';

class DanbooruBulkDownloadManagerBloc
    extends MobileBulkDownloadManagerBloc<DanbooruPost> {
  DanbooruBulkDownloadManagerBloc({
    required BuildContext context,
    required super.deviceInfo,
  }) : super(
            bulkPostDownloadBloc: DanbooruBulkDownloadBloc(
          downloader: BulkDownloader<DanbooruPost>(
            idSelector: (item) => item.id,
            downloadUrlSelector: (item) => item.downloadUrl,
            fileNameGenerator: DanbooruMd5OnlyFileNameGenerator(),
            deviceInfo: deviceInfo,
          ),
          postCountRepository: context.read<PostCountRepository>(),
          postRepository: context.read<DanbooruPostRepository>(),
          errorTranslator: translateBooruError,
          onDownloadDone: (path) => MediaScanner.loadMedia(path: path),
        ));
}
