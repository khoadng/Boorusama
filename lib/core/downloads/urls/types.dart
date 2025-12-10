// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../posts/post/types.dart';

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

abstract interface class DownloadSourceProvider {
  List<DownloadSource> getDownloadSources(BuildContext context, Post post);
}

class DownloadSource extends Equatable {
  const DownloadSource({
    required this.url,
    required this.name,
  });

  final String url;
  final String name;

  @override
  List<Object?> get props => [url, name];
}
