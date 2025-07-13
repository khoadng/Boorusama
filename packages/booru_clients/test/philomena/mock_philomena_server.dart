import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

class MockPhilomenaServer {
  HttpServer? _server;
  int _requestCount = 0;
  int _searchRequestCount = 0;
  DateTime? _lastReset;
  bool _shouldBlock = false;
  bool _shouldChallenge = false;

  Future<String> start() async {
    final handler = Pipeline().addHandler(_handleRequest);

    _server = await shelf_io.serve(handler, 'localhost', 0);
    return 'http://localhost:${_server!.port}';
  }

  Future<void> stop() async {
    await _server?.close();
  }

  void triggerBlock() => _shouldBlock = true;
  void triggerChallenge() => _shouldChallenge = true;
  void reset() {
    _requestCount = 0;
    _searchRequestCount = 0;
    _shouldBlock = false;
    _shouldChallenge = false;
    _lastReset = DateTime.now();
  }

  Response _handleRequest(Request request) {
    // Reset counters every 10 seconds for testing
    final now = DateTime.now();
    if (_lastReset == null || now.difference(_lastReset!).inSeconds >= 10) {
      _requestCount = 0;
      _searchRequestCount = 0;
      _lastReset = now;
    }

    // Simulate forced errors
    if (_shouldBlock) {
      return Response(500, body: '');
    }
    if (_shouldChallenge) {
      return Response(501, body: '<html>Challenge page</html>');
    }

    // Check rate limits
    if (request.url.path.startsWith('api/v1/json/search')) {
      _searchRequestCount++;
      if (_searchRequestCount > 20) {
        return Response(429, body: 'Search rate limit exceeded');
      }
    } else {
      _requestCount++;
      if (_requestCount > 30) {
        return Response(429, body: 'Rate limit exceeded');
      }
    }

    // Return mock response
    if (request.url.path.contains('search/images')) {
      return Response.ok(
        '{"images": [], "total": 0}',
        headers: {'Content-Type': 'application/json'},
      );
    } else if (request.url.path.contains('search/tags')) {
      return Response.ok(
        '{"tags": []}',
        headers: {'Content-Type': 'application/json'},
      );
    } else if (request.url.path.contains('images/')) {
      return Response.ok(
        _kDummyImageResponse,
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.notFound('Not found');
  }
}

const _kDummyImageResponse = '''
{
  "image": {
    "source_url": "",
    "spoilered": false,
    "created_at": "1970-01-01T00:00:00Z",
    "deletion_reason": null,
    "width": 0,
    "tag_count": 0,
    "size": 0,
    "animated": false,
    "downvotes": 0,
    "orig_sha512_hash": null,
    "hidden_from_users": false,
    "representations": {
      "full": "",
      "small": "",
      "thumb_tiny": "",
      "thumb_small": "",
      "thumb": "",
      "medium": "",
      "large": "",
      "tall": ""
    },
    "mime_type": "",
    "tags": [],
    "description": "",
    "duration": 0.0,
    "aspect_ratio": 0.0,
    "upvotes": 0,
    "comment_count": 0,
    "faves": 0,
    "thumbnails_generated": false,
    "first_seen_at": "1970-01-01T00:00:00Z",
    "wilson_score": 0.0,
    "source_urls": [],
    "orig_size": 0,
    "intensities": {
      "nw": 0.0,
      "ne": 0.0,
      "sw": 0.0,
      "se": 0.0
    },
    "format": "",
    "id": 0,
    "view_url": "",
    "name": "",
    "height": 0,
    "uploader_id": 0,
    "uploader": "",
    "updated_at": "1970-01-01T00:00:00Z",
    "processed": false,
    "score": 0,
    "tag_ids": [],
    "duplicate_of": null,
    "sha512_hash": ""
  },
  "interactions": []
}
''';
