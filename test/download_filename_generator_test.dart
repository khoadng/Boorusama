// Package imports:
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/downloads/filename/types.dart';
import 'package:boorusama/core/posts/post/types.dart';
import 'package:boorusama/core/posts/rating/types.dart';
import 'package:boorusama/core/posts/sources/types.dart';
import 'package:boorusama/core/settings/types.dart';

void main() {
  group('DownloadFileNameBuilder', () {
    final builder = DownloadFileNameBuilder<Post>(
      defaultFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      defaultBulkDownloadFileNameFormat: kDefaultCustomDownloadFileNameFormat,
      sampleData: kDanbooruPostSamples,
      tokenHandlers: const [],
    );

    const config = BooruConfigDownload(
      fileNameFormat: null,
      bulkFileNameFormat: null,
      location: null,
    );

    test('uses default bulk format when config has no custom format', () async {
      final fileName = await builder.generateForBulkDownload(
        Settings.defaultSettings,
        config,
        _TestPost(format: 'jpg'),
        downloadUrl: 'http://127.0.0.1:45869/get_files/file?file_id=42',
      );

      expect(fileName, '42_01234567.jpg');
    });

    test('uses post format when download url has no extension', () async {
      final fileName = await builder.generate(
        Settings.defaultSettings,
        config,
        _TestPost(format: '.png'),
        downloadUrl: 'http://127.0.0.1:45869/get_files/file?file_id=42',
      );

      expect(fileName, '42_01234567.png');
    });
  });
}

class _TestPost extends SimplePost {
  _TestPost({
    required super.format,
  }) : super(
         id: 42,
         thumbnailImageUrl: '',
         sampleImageUrl: '',
         originalImageUrl: '',
         tags: const {},
         rating: Rating.general,
         hasComment: false,
         isTranslated: false,
         hasParentOrChildren: false,
         source: PostSource.none(),
         score: 0,
         duration: 0,
         fileSize: 0,
         hasSound: null,
         height: 100,
         md5: '0123456789abcdef0123456789abcdef',
         videoThumbnailUrl: '',
         videoUrl: '',
         width: 100,
         uploaderId: null,
         metadata: null,
       );
}
