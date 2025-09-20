import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:xml/xml.dart';

import '../../gelbooru/types/types.dart';
import '../types.dart';

GelbooruV2Posts parseGelPosts(
  Response response,
  Map<String, dynamic> context,
) {
  final baseUrl = context['baseUrl'] as String? ?? '';
  final data = response.data;

  final result = switch (data) {
    final Map m => () {
      final count = m['@attributes']['count'] as int?;

      return (
        posts: m.containsKey('post')
            ? (m['post'] as List)
                  .map((item) => PostV2Dto.fromJson(item, baseUrl))
                  .toList()
            : <PostV2Dto>[],
        count: count,
      );
    }(),
    final List l => (
      posts: l.map((item) => PostV2Dto.fromJson(item, baseUrl)).toList(),
      count: null,
    ),
    final String s => (
      posts: (jsonDecode(s) as List<dynamic>)
          .map<PostV2Dto>((item) => PostV2Dto.fromJson(item, baseUrl))
          .toList(),
      count: null,
    ),
    _ => (
      posts: <PostV2Dto>[],
      count: null,
    ),
  };

  final filterNulls = result.posts.where((e) => e.hash != null).toList();

  return GelbooruV2Posts(
    posts: filterNulls,
    count: result.count,
  );
}

List<AutocompleteDto> parseGelAutocomplete(
  Response response,
  Map<String, dynamic> context,
) {
  return switch (response.data) {
    final List l => l.map((item) => AutocompleteDto.fromJson(item)).toList(),
    final String s =>
      (jsonDecode(s) as List<dynamic>)
          .map((item) => AutocompleteDto.fromJson(item))
          .toList(),
    _ => <AutocompleteDto>[],
  };
}

List<CommentDto> parseGelComments(
  Response response,
  Map<String, dynamic> context,
) {
  final dtos = <CommentDto>[];
  final xmlDocument = XmlDocument.parse(response.data);
  final comments = xmlDocument.findAllElements('comment');
  for (final item in comments) {
    dtos.add(CommentDto.fromXml(item));
  }
  return dtos;
}

List<NoteDto> parseGelNotesHtml(
  Response response,
  Map<String, dynamic> context,
) {
  final html = response.data as String;
  final document = parse(html);
  final noteContainer = document.getElementById('note-container');

  final notes = noteContainer?.getElementsByClassName('note-box').map((e) {
    final style = e.attributes['style'];
    final idString = e.attributes['id'];

    if (style == null || idString == null) return null;

    final width = int.tryParse(
      RegExp(r'width: (\d+)px;').firstMatch(style)?.group(1) ?? '',
    );
    final height = int.tryParse(
      RegExp(r'height: (\d+)px;').firstMatch(style)?.group(1) ?? '',
    );
    final top = int.tryParse(
      RegExp(r'top: (\d+)px;').firstMatch(style)?.group(1) ?? '',
    );
    final left = int.tryParse(
      RegExp(r'left: (\d+)px;').firstMatch(style)?.group(1) ?? '',
    );
    final id = int.tryParse(
      RegExp(r'note-box-(\d+)').firstMatch(idString)?.group(1) ?? '',
    );

    return NoteDto(
      id: id,
      width: width,
      height: height,
      y: top,
      x: left,
    );
  }).toList();

  final notesWithBody = notes?.where((e) => e != null).map((e) => e!).map((e) {
    final body = document.getElementById('note-body-${e.id}')?.text;
    return e.copyWith(body: () => body);
  }).toList();

  return notesWithBody ?? [];
}

List<TagDto> parseGelTagsHtml(Response response, Map<String, dynamic> context) {
  final html = response.data as String;
  final document = parse(html);
  final sideBar = document.getElementById('tag-sidebar');

  final copyrightTags =
      sideBar?.querySelectorAll('li.tag-type-copyright') ?? [];
  final characterTags =
      sideBar?.querySelectorAll('li.tag-type-character') ?? [];
  final artistTags = sideBar?.querySelectorAll('li.tag-type-artist') ?? [];
  final generalTags = sideBar?.querySelectorAll('li.tag-type-general') ?? [];

  final metaTags = sideBar?.querySelectorAll('li.tag-type-meta') ?? [];
  final metadataTags = sideBar?.querySelectorAll('li.tag-type-metadata') ?? [];
  final effectiveMetaTags = metaTags.isNotEmpty ? metaTags : metadataTags;

  return [
    for (final tag in artistTags) TagDto.fromHtml(tag, 1),
    for (final tag in copyrightTags) TagDto.fromHtml(tag, 3),
    for (final tag in characterTags) TagDto.fromHtml(tag, 4),
    for (final tag in generalTags) TagDto.fromHtml(tag, 0),
    for (final tag in effectiveMetaTags) TagDto.fromHtml(tag, 5),
  ];
}
