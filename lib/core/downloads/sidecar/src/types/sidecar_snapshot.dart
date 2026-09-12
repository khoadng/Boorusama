import 'package:equatable/equatable.dart';

import '../../../../posts/post/types.dart';
import 'sidecar_format.dart';

/// Deliberately excludes request URLs, headers, credentials and UI defaults.
class SidecarSnapshot extends Equatable {
  SidecarSnapshot({
    required this.format,
    required Iterable<String> tags,
    required this.quality,
    this.postId,
    String? site,
    String? postUrl,
    Iterable<String> urls = const [],
  }) : site = site != null && isPublicSourceUrl(site) ? site : null,
       postUrl = postUrl != null && isPublicSourceUrl(postUrl) ? postUrl : null,
       tags = List.unmodifiable(tags.toSet().toList()..sort()),
       urls = List.unmodifiable(
         [...urls, ?postUrl].where(isPublicSourceUrl).toSet().toList()..sort(),
       );

  factory SidecarSnapshot.fromPost(
    Post post, {
    required SidecarFormat format,
    required String quality,
    String? site,
    String? postUrl,
    Iterable<String>? urls,
  }) => SidecarSnapshot(
    format: format,
    tags: post.tags,
    quality: quality,
    postId: post.sitePostId,
    site: site,
    postUrl: postUrl,
    urls: urls ?? post.knownSourceUrls,
  );

  factory SidecarSnapshot.fromJson(Map<String, dynamic> json) =>
      SidecarSnapshot(
        format: SidecarFormat.parse(json['format']),
        tags: (json['tags'] as List).cast<String>(),
        quality: json['quality'] as String,
        postId: json['post_id'] as String?,
        site: json['site'] as String?,
        postUrl: json['post_url'] as String?,
        urls: (json['urls'] as List).cast<String>(),
      );

  final SidecarFormat format;
  final List<String> tags;
  final List<String> urls;
  final String quality;
  final String? postId;
  final String? site;
  final String? postUrl;

  Map<String, dynamic> toJson() => {
    'format': format.name,
    'tags': tags,
    'urls': urls,
    'quality': quality,
    'post_id': postId,
    'site': site,
    'post_url': postUrl,
  };

  @override
  List<Object?> get props => [
    format,
    tags,
    urls,
    quality,
    postId,
    site,
    postUrl,
  ];
}

/// Only provenance URLs, never signed media endpoints or local API addresses.
bool isPublicSourceUrl(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      !['http', 'https'].contains(uri.scheme) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasFragment) {
    return false;
  }
  final host = uri.host.toLowerCase();
  if (host == 'localhost' ||
      host.endsWith('.local') ||
      host.contains(':') ||
      RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(host) ||
      uri.path.startsWith('/get_files/')) {
    return false;
  }
  // Preserve common canonical post query parameters, not arbitrary tokens.
  const allowed = {'id', 'page', 's', 'pid', 'tags'};
  return uri.queryParameters.keys.every(allowed.contains);
}
