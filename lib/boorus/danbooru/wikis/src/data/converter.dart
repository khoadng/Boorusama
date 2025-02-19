// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/wiki.dart';

Wiki? wikiDtoToWiki(WikiDto d) {
  try {
    return Wiki(
      body: d.body!,
      id: d.id!,
      title: d.title!,
      otherNames: List<String>.of(d.otherNames!),
    );
  } catch (e) {
    return null;
  }
}
