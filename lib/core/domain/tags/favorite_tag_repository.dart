// Project imports:
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/core/domain/tags/favorite_tag.dart';

abstract class FavoriteTagRepository {
  Future<List<FavoriteTag>> get(String name);

  Future<List<FavoriteTag>> getAll();

  Future<FavoriteTag?> getFirst(String name);

  Future<FavoriteTag?> deleteFirst(String name);

  Future<FavoriteTag> create({
    required String name,
    BooruType? type,
    required int order,
  });
}
