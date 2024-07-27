// Project imports:
import 'favorited_tags.dart';

abstract class FavoriteTagRepository {
  Future<List<FavoriteTag>> get(String name);

  Future<List<FavoriteTag>> getAll();

  Future<FavoriteTag?> getFirst(String name);

  Future<FavoriteTag?> deleteFirst(String name);

  Future<FavoriteTag> create({
    required String name,
    List<String>? labels,
  });

  Future<List<FavoriteTag>> createFrom(List<FavoriteTag> tags);

  Future<FavoriteTag?> updateFirst(String name, FavoriteTag tag);
}
