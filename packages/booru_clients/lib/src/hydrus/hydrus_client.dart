// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kClientApiAccessKey = 'Hydrus-Client-API-Access-Key';

typedef HydrusFiles = ({List<FileDto> files, int? count});

class HydrusClient {
  HydrusClient({
    required String baseUrl,
    required String apiKey,
    Dio? dio,
  }) {
    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl,
          ),
        );
    if (apiKey.isNotEmpty) {
      _dio.options.headers[_kClientApiAccessKey] = apiKey;
    }
  }

  late Dio _dio;

  Map<String, String> get apiKeyHeader =>
      switch (_dio.options.headers[_kClientApiAccessKey]) {
        final String apiKey when apiKey.isNotEmpty => {
          _kClientApiAccessKey: apiKey,
        },
        _ => {},
      };

  Future<AccessKeyVerificationDto> verifyAccessKey() async {
    final response = await _dio.get('/verify_access_key');

    return AccessKeyVerificationDto.fromJson(_responseMap(response.data));
  }

  //TODO: should be handle in a separated class
  List<ServiceDto>? _services;
  DateTime? _servicesLastUpdated;

  Future<HydrusFiles> getFiles({
    dynamic tags,
    int page = 1,
    int? limit,
    String? sessionId,
  }) async {
    final lim = limit ?? 20;
    final searchTags = _searchTags(tags);
    final hasUserLimit = searchTags.any(
      (tag) => tag.trim().toLowerCase().startsWith('system:limit'),
    );
    final requestedCount = page * lim;
    final searchLimit = requestedCount + 1;

    if (!hasUserLimit) {
      searchTags.add('system:limit = $searchLimit');
    }

    final response = await _dio.get(
      '/get_files/search_files',
      queryParameters: {
        'tags': jsonEncode(searchTags),
      },
    );

    final data = _responseMap(response.data);
    final ids = switch (data['file_ids']) {
      final List list => [for (final id in list) id as int],
      _ => <int>[],
    };

    if (ids.isEmpty) return (files: <FileDto>[], count: 0);

    // paginate the results
    var start = (page - 1) * lim;
    var end = start + lim;

    if (start < 0) {
      start = 0;
    }

    if (end > ids.length) {
      end = ids.length;
    }

    // make sure start is less than end
    if (start >= end) return (files: <FileDto>[], count: 0);

    final fileIds = ids.sublist(start, end);

    final files = await _getFiles(fileIds: fileIds);

    return (
      files: files,
      count: !hasUserLimit && ids.length > requestedCount ? null : ids.length,
    );
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

    final data = _responseMap(res.data);
    final metadata = switch (data['metadata']) {
      final List list => list,
      _ => <dynamic>[],
    };
    final services = _servicesFromResponse(data);

    _updateServices(services);

    return metadata
        .map(
          (e) => FileDto.fromJson(
            _responseMap(e),
            _dio.options.baseUrl,
            services,
          ),
        )
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

    return _services!;
  }

  Future<List<ServiceDto>> getServices() async {
    final res = await _dio.get('/get_services');

    final services = _servicesFromResponse(_responseMap(res.data));

    _updateServices(services);

    return services;
  }

  void _updateServices(List<ServiceDto> services) {
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

    final data = _responseMap(response.data);
    final tags = switch (data['tags']) {
      final List list => list,
      _ => <dynamic>[],
    };

    return tags.map((e) => AutocompleteDto.fromJson(_responseMap(e))).toList();
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

Map<String, dynamic> _responseMap(dynamic data) {
  return switch (data) {
    final Map<String, dynamic> map => map,
    final Map map => map.map((key, value) => MapEntry(key.toString(), value)),
    final String text => _responseMap(jsonDecode(text)),
    _ => throw const FormatException('Expected a JSON object response'),
  };
}

List<String> _searchTags(dynamic tags) {
  final searchTags = switch (tags) {
    '' || null => <String>[],
    final List list => [for (final tag in list) tag.toString()],
    final String tag => [tag],
    _ => [tags.toString()],
  }..removeWhere((tag) => tag.trim().isEmpty);

  return searchTags.isEmpty ? ['system:everything'] : searchTags;
}

List<ServiceDto> _servicesFromResponse(Map<String, dynamic> data) {
  final servicesV2 = switch (data['services_v2']) {
    final List list =>
      list
          .map((service) => ServiceDto.fromJson(_responseMap(service)))
          .nonNulls
          .toList(),
    _ => <ServiceDto>[],
  };

  if (servicesV2.isNotEmpty) return servicesV2;

  return switch (data['services']) {
    final Map services =>
      services.entries
          .map(
            (entry) => ServiceDto.fromJson(
              _responseMap(entry.value),
              entry.key.toString(),
            ),
          )
          .nonNulls
          .toList(),
    _ => <ServiceDto>[],
  };
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
