// Dart imports:
import 'dart:typed_data';

// Package imports:
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';

class AlternativeDownloadService implements IDownloadService<Post> {
  AlternativeDownloadService({
    required FileNameGenerator fileNameGenerator,
  }) : _fileNameGenerator = fileNameGenerator;
  final FileNameGenerator _fileNameGenerator;

  @override
  void dispose() {}

  @override
  Future<void> download(item, {String? path}) async {
    final dio = Dio();
    try {
      final response = await dio.get(
        item.downloadUrl,
        // onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      final fileName = _fileNameGenerator.generateFor(item);
      await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        name: fileName,
      );
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Future<void> init() async {}
}
