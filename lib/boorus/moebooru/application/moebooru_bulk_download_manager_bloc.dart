// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_scanner/media_scanner.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/downloads/post_file_name_generator.dart';
import 'package:boorusama/boorus/danbooru/errors.dart';
import 'package:boorusama/boorus/danbooru/infra/services/bulk_downloader.dart';
import 'package:boorusama/boorus/moebooru/application/moebooru_bulk_post_download_bloc.dart';
import 'package:boorusama/core/application/downloads.dart';
import 'package:boorusama/core/domain/posts.dart';

class MoebooruBulkDownloadManagerBloc
    extends MobileBulkDownloadManagerBloc<Post> {
  MoebooruBulkDownloadManagerBloc({
    required BuildContext context,
    required super.deviceInfo,
  }) : super(
            bulkPostDownloadBloc: MoebooruBulkPostDownloadBloc(
          downloader: BulkDownloader<Post>(
            idSelector: (item) => item.id,
            downloadUrlSelector: (item) => item.downloadUrl,
            fileNameGenerator: Md5OnlyFileNameGenerator(),
            deviceInfo: deviceInfo,
          ),
          postRepository: context.read<PostRepository>(),
          errorTranslator: translateBooruError,
          onDownloadDone: (path) => MediaScanner.loadMedia(path: path),
        ));
}
