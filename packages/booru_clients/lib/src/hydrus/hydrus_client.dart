// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kClientApiAccessKey = 'Hydrus-Client-API-Access-Key';

typedef HydrusFiles = ({
  List<FileDto> files,
  int? count,
});

class HydrusClient {
  HydrusClient({
    required String baseUrl,
    required String apiKey,
    Dio? dio,
  }) {
    _dio = dio ??
        Dio(BaseOptions(
          baseUrl: baseUrl,
        ));
    if (apiKey.isNotEmpty) {
      _dio.options.headers[_kClientApiAccessKey] = apiKey;
    }
  }

  late Dio _dio;

  Map<String, String> get apiKeyHeader => {
        _kClientApiAccessKey:
            _dio.options.headers[_kClientApiAccessKey] as String,
      };

  // virtual session for each search, since hydrus doesn't use pagination
  final _sessions = <String, SearchSession>{};

  //TODO: should be handle in a separated class
  Map<String, dynamic>? _services;
  DateTime? _servicesLastUpdated;

  Future<HydrusFiles> getFiles({
    dynamic tags,
    int page = 1,
    int? limit,
    String? sessionId,
  }) async {
    final params = switch (tags) {
      '' || null => jsonEncode(['system:everything']),
      final List l =>
        l.isEmpty ? jsonEncode(['system:everything']) : jsonEncode(l),
      _ => jsonEncode(tags),
    };

    //TODO: for now just clear the session, doesn't have a use case yet
    _sessions.clear();

    final response = await _dio.get(
      '/get_files/search_files',
      queryParameters: {
        'tags': params,
      },
    );

    final data = response.data;

    final ids = data['file_ids'] as List<dynamic>;

    if (ids.isEmpty) return (files: <FileDto>[], count: 0);

    // check if user wants to continue session, else create new session
    final session = sessionId != null
        ? _sessions[sessionId]!
        : SearchSession.create(
            tags: tags, fileIds: [for (final id in ids) id as int]);

    if (sessionId == null) {
      _sessions[session.id] = session;
    }

    final lim = limit ?? 20;

    // paginate the results
    var start = (page - 1) * lim;
    var end = start + lim;

    if (start < 0) {
      start = 0;
    }

    if (end > session.fileIds.length) {
      end = session.fileIds.length;
    }

    // make sure start is less than end
    if (start >= end) return (files: <FileDto>[], count: 0);

    final fileIds = session.fileIds.sublist(start, end);

    final files = await _getFiles(fileIds: fileIds);

    return (files: files, count: session.fileIds.length);
  }

  Future<FileDto?> getFile(int id) async {
    final files = await _getFiles(fileIds: [id]);
    return files.firstOrNull;
  }

  Future<List<FileDto>> _getFiles({
    required List<int> fileIds,
  }) async {
    final res = await _dio.get(
      '/get_files/file_metadata',
      queryParameters: {
        'file_ids': jsonEncode(fileIds),
      },
    );

    final metadata = res.data['metadata'] as List<dynamic>;
    final services = res.data['services'] as Map<String, dynamic>;

    _services = services;

    _updateServices(services);

    return metadata
        .map((e) => FileDto.fromJson(
              e,
              _dio.options.baseUrl,
              services,
            ))
        .toList();
  }

  Future<List<ServiceDto>> getServicesCached() async {
    if (_services == null) {
      return getServices();
    }

    if (_servicesLastUpdated == null ||
        DateTime.now().difference(_servicesLastUpdated!) >
            const Duration(minutes: 5)) {
      return getServices();
    }

    return _services!.entries
        .map((e) => ServiceDto.fromJson(e.value, e.key))
        .nonNulls
        .toList();
  }

  Future<List<ServiceDto>> getServices() async {
    final res = await _dio.get('/get_services');

    final services = res.data['services'] as Map<String, dynamic>;

    _updateServices(services);

    return services.entries
        .map((e) => ServiceDto.fromJson(e.value, e.key))
        .nonNulls
        .toList();
  }

  void _updateServices(Map<String, dynamic> services) {
    _services = services;
    _servicesLastUpdated = DateTime.now();
  }

  Future<List<AutocompleteDto>> getAutocomplete({
    required String query,
  }) async {
    final response = await _dio.get(
      '/add_tags/search_tags',
      queryParameters: {
        'search': query,
        'tag_display_type': 'display',
      },
    );

    final data = response.data['tags'] as List<dynamic>;

    return data.map((e) => AutocompleteDto.fromJson(e)).toList();
  }

  Future<bool> setRating({
    required int fileId,
    required String ratingServiceKey,
    required dynamic rating,
  }) async {
    try {
      final _ = await _dio.post(
        '/edit_ratings/set_rating',
        data: {
          'file_id': fileId,
          'rating_service_key': ratingServiceKey,
          'rating': rating,
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}

extension HydrusClientX on HydrusClient {
  Future<bool> changeLikeStatus({
    required int fileId,
    required bool? liked,
  }) async {
    final services = await getServicesCached();
    final key = getLikeDislikeRatingKey(services);

    if (key == null) return false;

    return setRating(
      fileId: fileId,
      ratingServiceKey: key,
      rating: liked,
    );
  }
}

class SearchSession {
  SearchSession({
    required this.id,
    required this.tags,
    required this.fileIds,
  });

  SearchSession.create({required this.tags, required this.fileIds})
      : id = DateTime.now().millisecondsSinceEpoch.toString();

  final String id;
  final dynamic tags;
  final List<int> fileIds;
}
