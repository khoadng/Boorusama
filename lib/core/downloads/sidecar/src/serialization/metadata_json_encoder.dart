import 'dart:convert';

import '../types/sidecar_snapshot.dart';

String encodeMetadataJson(SidecarSnapshot snapshot, String filename) =>
    '${const JsonEncoder.withIndent('  ').convert({
      'schema_version': 1,
      if (snapshot.postId != null || snapshot.site != null || snapshot.postUrl != null) 'post': {
          if (snapshot.site != null) 'site': snapshot.site,
          if (snapshot.postId != null) 'id': snapshot.postId,
          if (snapshot.postUrl != null) 'url': snapshot.postUrl,
        },
      'tags': snapshot.tags,
      'urls': snapshot.urls,
      'media': {'filename': filename, 'quality': snapshot.quality},
    })}\n';
