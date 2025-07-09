// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../posts/post/post.dart';

class DownloadUrlData extends Equatable {
  const DownloadUrlData({
    required this.url,
    required this.cookie,
  });

  const DownloadUrlData.urlOnly(
    this.url,
  ) : cookie = null;

  final String url;
  final String? cookie;

  @override
  List<Object?> get props => [url, cookie];
}

abstract interface class DownloadFileUrlExtractor {
  Future<DownloadUrlData?> getDownloadFileUrl({
    required Post post,
    required String quality,
  });
}
