// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';

abstract class FavoriteTagRepository {
  Future<List<FavoriteTag>> get(String name);

  Future<List<FavoriteTag>> getAll();

  Future<FavoriteTag?> getFirst(String name);

  Future<FavoriteTag?> deleteFirst(String name);

  Future<FavoriteTag> create({
    required String name,
    List<String>? labels,
  });

  Future<FavoriteTag?> updateFirst(String name, FavoriteTag tag);
}
