// Dart imports:
import 'dart:io';

// Package imports:
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

// Project imports:
import 'package:boorusama/core/application/application.dart';
import 'package:boorusama/core/domain/file_name_generator.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/domain/user_agent_generator.dart';

class WindowDownloader implements DownloadService<Post> {
  WindowDownloader(this._fileNameGenerator, this._agentGenerator);
  late String? _localPath;
  late String? _savedDir;
  final FileNameGenerator _fileNameGenerator;
  final UserAgentGenerator _agentGenerator;

  @override
  Future<void> init() async {
    _localPath = (await getDownloadsDirectory())?.path;
    final savedDir = Directory(_localPath!);
    final bool hasExisted = savedDir.existsSync();
    if (!hasExisted) {
      await savedDir.create();
    }
    _savedDir = savedDir.path;
  }

  @override
  Future<void> download(
    item, {
    String? path,
    String? folderName,
  }) async {
    if (_localPath == null || _savedDir == null) {
      throw Exception('Uninitialzed');
    }

    final dio = Dio(BaseOptions(
      headers: {
        'User-Agent': _agentGenerator.generate(),
      },
    ));
    final fileName = _fileNameGenerator.generateFor(item);
    try {
      final file = File('$_savedDir${Platform.pathSeparator}$fileName');

      await dio.download(
        item.downloadUrl,
        file.path,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  // ignore: no-empty-block
  void dispose() {}
}
