// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:html/parser.dart';

// Project imports:
import 'gelbooru_client_favorites.dart';
import 'types/post_v1_dto.dart';

class GelbooruV1Client with GelbooruClientFavorites {
  GelbooruV1Client({
    required String baseUrl,
    this.passHash,
    this.userId,
    Map<String, String>? headers,
    Dio? dio,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               headers: headers ?? {},
             ),
           );

  final Dio _dio;

  @override
  final String? passHash;

  @override
  final String? userId;

  @override
  Dio get dio => _dio;

  Future<List<PostV1Dto>> getPosts({
    int? page,
    List<String>? tags,
  }) async {
    final tagString = tags == null || tags.isEmpty ? 'all' : tags.join('+');

    final response = await _dio.get(
      '/index.php',
      queryParameters: {
        'page': 'post',
        's': 'list',
        'tags': tagString,
        if (page != null) 'pid': (page - 1) * 20,
      },
    );

    final document = parse(response.data);
    final data = document.getElementsByClassName('thumb');

    return data.map((e) => PostV1Dto.fromHTML(e)).toList();
  }

  Future<PostV1Dto?> getPost(int id) async {
    try {
      final response = await _dio.get(
        '/index.php',
        queryParameters: {
          'page': 'post',
          's': 'view',
          'id': id,
        },
      );

      final document = parse(response.data);

      // Extract image URL
      final imageElement = document.querySelector('#image');
      if (imageElement == null) return null;

      final imageUrl = imageElement.attributes['src'];
      if (imageUrl == null) return null;

      // Extract statistics
      final statsSection =
          document.querySelector('#tag_list strong')?.parent?.text.trim() ?? '';

      // final dateMatch =
      //     RegExp(r'Posted: ([0-9-]+ [0-9:]+)').firstMatch(statsSection);
      // final uploaderMatch = RegExp(r'By: (.+)').firstMatch(statsSection);
      // final sizeMatch = RegExp(r'Size: (\d+)x(\d+)').firstMatch(statsSection);
      final ratingMatch = RegExp(r'Rating: (.+)').firstMatch(statsSection);
      final scoreMatch = RegExp(r'Score: (.+)').firstMatch(statsSection);

      // Extract tags from tag list
      final tagElements = document.querySelectorAll('#tag_list ul li a');
      final tags = tagElements
          .map((e) => e.text.trim())
          .where((tag) => tag.isNotEmpty)
          .join(' ');

      // // Parse dimensions
      // final width =
      //     sizeMatch != null ? int.tryParse(sizeMatch.group(1) ?? '0') : null;
      // final height =
      //     sizeMatch != null ? int.tryParse(sizeMatch.group(2) ?? '0') : null;

      // Extract MD5 from URL
      String? md5;
      final md5Match = RegExp(r'/([a-f0-9]{32})\.').firstMatch(imageUrl);
      if (md5Match != null && md5Match.groupCount >= 1) {
        md5 = md5Match.group(1);
      }

      return PostV1Dto(
        id: id,
        fileUrl: imageUrl,
        sampleUrl: imageUrl, // Same as file URL for v1 sites typically
        previewUrl: imageUrl,
        tags: tags,
        md5: md5,
        rating: ratingMatch?.group(1)?.toLowerCase(),
        score: scoreMatch != null
            ? int.tryParse(scoreMatch.group(1) ?? '0')
            : null,
      );
    } catch (e) {
      // Log error or handle exception
      return null;
    }
  }
}
